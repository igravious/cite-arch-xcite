include Xcite::Cite

RSpec.describe Xcite do
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

	# CtsUrn
	it 'should have a namespace' do
		expect(simple_passage_urn.namespace).to eq('UCCphilText')
	end

  # it 'does something useful' do
  #  expect(false).to eq(true)
  # end

	# CtsUrn	
	it 'should hav a hierarchical work component' do
		expect(simple_passage_urn.work_component).to eq('aristotle.nico.peters1893')
	end

	# CtsUrn
	it 'should determine the level of the work component' do
		expect(simple_passage_urn.work_level == WorkLevel::Version)
	end

	# CtsUrn
	it 'should allow a none option for passage component' do
		work_only = CtsUrn.new('urn:cts:UCCphilText:aristotle.nico.peters1893:')
		expect(work_only.passage_component_option).to be nil
	end

end
