# frozen_string_literal: true

module Bloomr
  module Credit
    def get_credit_data(token, order_id)
      body = {
      }

      headers = {
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }

      response = request(
        "/v2/data-access/orders/#{order_id}/full-report",
        :get,
        body,
        headers
      )

      parse_all_content(response)
    end

    def order_credit(token, consumer_id, portfolio_id, sku)
      attributes = {
        consumer_id: consumer_id,
        portfolio_id: portfolio_id,
        sku: sku
      }

      body = {
        data: {
          type: 'order',
          attributes: attributes
        }
      }

      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }

      response = request(
        "/v2/data-access/orders",
        :post,
        body,
        headers
      )

      response[:data][:id]
    end

    def get_decision(credit_data)
      credit_score_exists = credit_data.key?('credit_scores')
      months_recent_delinquency_exists = credit_data.key?('attributes') && credit_data['attributes'].key?('months_recent_delinquency')

      if !credit_score_exists || !months_recent_delinquency_exists
        raise Error, 'Insufficient data provided. Missing `credit_data["credit_scores"]` and/or `credit_data["attributes"]`.'
      else
        approved = (credit_data['credit_scores'].map { |score| score['value'] }.min >= 600) &&
                   (credit_data['attributes']['months_recent_delinquency'].to_i >= 24) &&
                   (!credit_data['attributes']['tradeline_dti'] || credit_data['attributes']['tradeline_dti'].to_i <= 35)

        denied = (credit_data['credit_scores'].map { |score| score['value'] }.min < 600) &&
                 (credit_data['attributes']['months_recent_delinquency'].to_i < 24) &&
                 (!credit_data['attributes']['tradeline_dti'] || credit_data['attributes']['tradeline_dti'].to_i < 35)
      end

      if credit_data['ofac_statuses']['reference'] != ""
        return "unable to process; #{credit_data['ofac_statuses']['issue_source']}"
      elsif approved
        return "decision: approved"
      elsif denied
        return "decision: denied"
      else
        return "decision: manual review required"
      end
    end

    private

    def parse_credit_scores(credit_scores)
      credit_scores.map do |data|
        score_reasons = data[:score_reasons]
        model = data[:model]
        value = data[:value]
        id = data[:id]
        credit_data_id = data[:credit_data_id]

        score_reasons.map do |reason|
          {
            model: model,
            value: value,
            id: id,
            credit_data_id: credit_data_id,
            score_id: reason[:id],
            reason_description: reason[:reason_description]
          }
        end
      end
    end

    def parse_credit_data_order(credit_data_order)
      data = {
        order_date: credit_data_order[:order_date],
        order_id: credit_data_order[:order_id],
        order_sku_id: credit_data_order[:order_sku_id],
        consumer_id: credit_data_order[:consumer_id]
      }
    end

    def parse_all_content(report)
      # Parse all attributes
      attributes = report.reject { |key, _| key == "credit_data_order" }
                         .values.flatten
                         .map { |row| row[:order_id] }
      # Credit_data_order
      credit_data_order = report[:credit_data_order]

      credit_data = parse_credit_data_order(credit_data_order)
      credit_scores = parse_credit_scores(credit_data_order[:credit_scores])
      mla_statuses = credit_data_order[:mla_statuses]
      ofac_statuses = credit_data_order[:ofac_statuses]
      tradelines = credit_data_order[:tradelines]

      return {
        attributes:,
        credit_data:,
        credit_scores:,
        mla_statuses:,
        ofac_statuses:,
        tradelines:
      }
    end
  end
end
