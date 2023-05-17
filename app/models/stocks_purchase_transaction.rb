class StocksPurchaseTransaction < Transaction
  private

  def set_nature
    self.nature = :outflow
  end
end
