include Xcite::Cite

RSpec.describe "Xcite::Cite Basic" do
	# Something like
	#
	# I.1.H = BOOK I.: THE END.
	# I.1.0 = 1.: In all he does man seeks same good as end or means.
	# I.1.1 = Every art and every kind of inquiry, and likewise every act and purpose, seems to aim at some good: and so it has been well said that the good is that at which everything aims.
	#
	simple_passage_urn = CtsUrn.new('urn:cts:UCCphilText:aristotle.nico.peters1893:I.1.1')

	# Xcite
  it 'should have a version number' do
    expect(Xcite::VERSION).not_to be nil
	end
end
