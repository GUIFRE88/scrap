# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#format_number' do
    context 'when formatting small numbers' do
      it 'returns the number as string for numbers less than 1000' do
        expect(helper.format_number(0)).to eq('0')
        expect(helper.format_number(1)).to eq('1')
        expect(helper.format_number(99)).to eq('99')
        expect(helper.format_number(123)).to eq('123')
        expect(helper.format_number(999)).to eq('999')
      end
    end

    context 'when formatting numbers with thousands' do
      it 'adds dot separator for thousands' do
        expect(helper.format_number(1000)).to eq('1.000')
        expect(helper.format_number(1234)).to eq('1.234')
        expect(helper.format_number(9999)).to eq('9.999')
      end
    end

    context 'when formatting numbers with millions' do
      it 'adds multiple dot separators' do
        expect(helper.format_number(1000000)).to eq('1.000.000')
        expect(helper.format_number(1234567)).to eq('1.234.567')
        expect(helper.format_number(9999999)).to eq('9.999.999')
      end
    end

    context 'when formatting large numbers' do
      it 'handles numbers with billions' do
        expect(helper.format_number(1000000000)).to eq('1.000.000.000')
        expect(helper.format_number(1234567890)).to eq('1.234.567.890')
      end
    end

    context 'when formatting real-world profile numbers' do
      it 'formats followers count correctly' do
        expect(helper.format_number(29000)).to eq('29.000')
        expect(helper.format_number(7700)).to eq('7.700')
        expect(helper.format_number(216)).to eq('216')
      end

      it 'formats contributions count correctly' do
        expect(helper.format_number(1463)).to eq('1.463')
        expect(helper.format_number(663)).to eq('663')
      end

      it 'formats stars count correctly' do
        expect(helper.format_number(676)).to eq('676')
        expect(helper.format_number(7)).to eq('7')
      end
    end

    context 'when handling edge cases' do
      it 'handles zero correctly' do
        expect(helper.format_number(0)).to eq('0')
      end

      it 'handles string numbers' do
        expect(helper.format_number('1234')).to eq('1.234')
        expect(helper.format_number('999')).to eq('999')
      end

      it 'handles negative numbers' do
        expect(helper.format_number(-1234)).to eq('-1.234')
        expect(helper.format_number(-999)).to eq('-999')
      end
    end

    context 'when formatting with exact thousands' do
      it 'formats numbers that are exact multiples of 1000' do
        expect(helper.format_number(1000)).to eq('1.000')
        expect(helper.format_number(10000)).to eq('10.000')
        expect(helper.format_number(100000)).to eq('100.000')
        expect(helper.format_number(1000000)).to eq('1.000.000')
      end
    end
  end
end
