include Xcite::Cite

RSpec.describe "Xcite::Cite Structure" do
	simple_passage_urn = CtsUrn.new('urn:cts:UCCphilText:aristotle.nico.peters1893:I.1.1')

	# CtsUrnStructureSpec.scala

	# CtsUrn
	it 'should have a namespace' do
		expect(simple_passage_urn.namespace).to eq('UCCphilText')
	end

  # it 'does something useful' do
  #  expect(false).to eq(true)
  # end

	# CtsUrn	
	it 'should have a hierarchical work component' do
		expect(simple_passage_urn.work_component).to eq('aristotle.nico.peters1893')
	end

	# CtsUrn
	it 'should determine the level of the work component' do
		expect(simple_passage_urn.work_level == WorkLevel::Version)
	end

	# CtsUrn
	it 'should allow a none option for passage component' do
		work_only = CtsUrn.new('urn:cts:UCCphilText:aristotle.nico.peters1893:')
		expect(work_only.passage_component_option).to be_nil # TODO: should be able to test against None
	end

	# this is an extra one
	
	# CtsUrn
	it 'should raise an exception for malformed passage component' do
		expect {CtsUrn.new('urn:cts:UCCphilText:aristotle.nico.peters1893.:I.')}.to raise_exception(RCiteException)
	end
end
