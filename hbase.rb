bases = list
unless bases.nil?
    bases.each {|t| disable t; drop t}
end
n_splits = 10
create 'usertable', 'family', {SPLITS => (1..n_splits).map {|i| "user#{1000+i*(9999-1000)/n_splits}"}}
exit