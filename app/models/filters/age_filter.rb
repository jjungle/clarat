class AgeFilter < Filter
  extend Enumerize

  IDENTIFIER = [
    :babies, :toddler, :schoolkid, :adolescent, :young_adults
  ]
  enumerize :identifier, in: AgeFilter::IDENTIFIER
end
