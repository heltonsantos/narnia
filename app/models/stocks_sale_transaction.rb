class StocksSaleTransaction < Transaction
  private

  def set_nature
    self.nature = :inflow
  end
end
