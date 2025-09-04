class AddNumbersTool < ApplicationTool
  description 'Add two numbers and return the sum'

  arguments do
    required(:a).filled(:integer).description('First addend')
    required(:b).filled(:integer).description('Second addend')
  end

  def call(a:, b:)
    { result: Integer(a) + Integer(b) }
  end
end

