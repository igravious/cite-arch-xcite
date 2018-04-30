include Xcite::Cite

# TODO: there's a fail() but no succeed()?
def succeed
	expect(1).to be(1)
end

def unrecognised(e)
	fail("Unrecognized exception #{e.inspect}")
end

def should(str)
	'should '+str
end

# https://stackoverflow.com/questions/45785978/how-to-append-custom-message-to-rspec-exception-message

RSpec.describe "Xcite::Cite Validation" do
	# CtsUrnValidationSpec.scala

	# CtsUrn
	it should('construct a URN object from a well-formed string') do
		nico_string = 'urn:cts:UCCphilText:aristotle.nico:'
		nico_urn = CtsUrn.new(nico_string)
		# expect(nico_urn).to be_a(CtsUrn)
		if nico_urn.is_a? CtsUrn
			succeed
		else
			fail 'Did not construct a CtsUrn object from '+nico_string
		end
	end

	# CtsUrn
	it should('throw an ArgumentError if the URN string has too few components') do
		bad_nico_string = 'urn:cts:UCCphilText:aristotle.nico'
		expect {bad_nico_urn = CtsUrn.new(bad_nico_string)}.to raise_exception(ArgumentError)
		# The Scala code is
		# begin
		#		bad_nico_urn = CtsUrn.new(bad_nico_string)
		#	rescue => e
		#		case e
		#		when ArgumentError
		#			expect(e.message).to eq('requirement failed: invalid URN syntax: urn:cts:greekLit:tlg0012.tlg001. Wrong number of components.')
		#		else
		#			fail("Unrecognized exception " + e.class.to_s)
		#		end
		#	end
	end

	# CtsUrn
	it should('throw an RCiteException if the the URN string has a trailing :') do
		trailing_colon = 'urn:cts:UCCphilText:aristotle:I:'
		ought_not_to_construct = CtsUrn.new(trailing_colon)
		fail("Should not have formed URN with #{ought_not_to_construct.components.size} components.")
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq("requirement failed: invalid URN syntax: #{trailing_colon}. Wrong number of components.")
		when RCiteException
			expect(e.message).to eq('Invalid URN syntax: trailing colon in '+trailing_colon)
		else
			unrecognised(e)
		end
	end

	# CtsUrn
	it should('throw an ArgumentError if the `urn` component is missing') do
		bad_cts_part = 'XXX:cts:UCCphilText:aristotle.nico:'
		bad_cts_urn = CtsUrn.new(bad_cts_part)
		fail('Should not have formed URN')
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq("requirement failed: invalid URN syntax: #{bad_cts_part}. First component must be 'urn'.")
		else
			unrecognised(e)
		end
	end

	# CtsUrn
	it should('throw an ArgumentError if the `cts` component is missing') do
		bad_cts_part = 'urn:XXX:UCCphilText:aristotle.nico:'
		bad_cts_urn = CtsUrn.new(bad_cts_part)
		fail('Should not have formed URN')
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq("requirement failed: invalid URN syntax: #{bad_cts_part}. Second component must be 'cts'.")
		else
			unrecognised(e)
		end
	end

	# Syntax of work component
	it should('guarantee that the work component is non-empty') do
		nico = CtsUrn.new('urn:cts:UCCphilText:aristotle.nico:')
		expect(nico.work_component).not_to be(nil)
	end
	it should('throw an ArgumentError if a work component has more than 4 parts') do
		work_too_big = 'aristotle.nico.xlation.copy.oops'
		bad_urn_str = "urn:cts:UCCphilText:#{work_too_big}:"
		CtsUrn.new(bad_urn_str)
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid URN syntax. Too many parts in work component '+work_too_big)
		else
			unrecognised(e)
		end
	end

	# Syntax of passage component, more complex because of ranges
	it should('throw an RCiteException if a range has an empty first node') do
		empty_range_begin = 'urn:cts:greekLit:tlg0012.tlg001.msA:-1.10'
		CtsUrn.new(empty_range_begin)
		fail("Should not have formed URN")
	rescue => e
		case e
		when RCiteException
			expect(e.message).to eq('No range beginning defined in '+empty_range_begin)	
		else
			unrecognised(e)
		end
	end
	it should('throw an ArgumentError if a range has an empty second node') do
		empty_range_end = '1.1-'
		bad_urn_str = "urn:cts:greekLit:tlg0012.tlg001.msA:#{empty_range_end}"
		CtsUrn.new(bad_urn_str) # one of these is not like the other
		fail("Should not have formed URN")
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid URN syntax. Error in passage component '+empty_range_end)	
		else
			unrecognised(e)
		end
	end
	it should('throw an RCiteException if a range has more than two elements') do
		range_borked = '1.1-1.10-1.17'
		bad_urn_str = "urn:cts:greekLit:tlg0012.tlg001.msA:#{range_borked}"
		CtsUrn.new(bad_urn_str)
		fail("Should not have formed URN")
	rescue => e
		case e
		when RCiteException
			expect(e.message).to eq('invalid URN string: more than two elements in range '+range_borked)	
		else
			unrecognised(e)
		end
	end
	it should('identify a range reference as a range and not a node') do
		rangey = 'urn:cts:greekLit:tlg0012.tlg001.msA:1.1-1.10'
		u = CtsUrn.new(rangey)
		expect(u.is_range).to be true
		expect(u.is_point).to be false
	end
	it should('identify a range reference as a node and not a range') do
		rangey = 'urn:cts:greekLit:tlg0012.tlg001.msA:1.10'
		u = CtsUrn.new(rangey)
		expect(u.is_range).to be false
		expect(u.is_point).to be true
	end
	it should('throw an exception if there are empty components within a passage reference') do
		passage_dotted = 'urn:cts:greekLit:tlg0012.tlg001.msA:1.1...10'
		the_urn CtsUrn.new(passage_dotted)
    fail('Should not have created urn '+the_urn)
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid passage syntax in '+passage_dotted)	
		else
			unrecognised(e)
		end
	end

	it should('throw an exception if there are empty components within the first node of a range reference') do
		more_dotted = 'urn:cts:greekLit:tlg0012.tlg001.msA:1...1-1.7'
		the_urn = CtsUrn.new(more_dotted)
    fail('Should not have created urn '+the_urn)
  rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid passage syntax in range beginning of '+more_dotted)
		else
			unrecognised(e)
		end
	end
  it should('throw an exception if there are empty components within the second node of a range reference') do
		more_dotted = 'urn:cts:greekLit:tlg0012.tlg001.msA:1.1-1...7'
    the_urn = CtsUrn.new(more_dotted)
    fail('Should not have created urn '+the_urn)
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid passage syntax in range ending of '+more_dotted)
		else
			unrecognised(e)
		end
	end

  it should('throw an exception if there are empty components within the work reference') do
		empty_work = 'urn:cts:greekLit:tlg0012..tlg001:1.1'
    the_urn = CtsUrn.new(empty_work)
		fail('Should not have created urn '+the_urn)
	rescue => e
		case e
		when ArgumentError
      expect(e.message).to eq('requirement failed: invalid work syntax in '+empty_work)
    else
			unrecognised(e)
		end
	end
  it should('throw an exception if there are leading periods in the passage component') do
		leading_periods = 'urn:cts:greekLit:tlg0012.tlg001:.1.1'
		the_urn = CtsUrn.new(leading_periods)
    fail('Should not have created URN with bad passage component inluding leading period')
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid passage syntax in '+leading_periods)
		else
			fail('Should have thrown ArgumentError, not '+e.message)
		end
	end
  it should('throw an exception if there are trailing periods in the passage component') do
		passage_component = '1.1.'
		trailing_periods = 'urn:cts:greekLit:tlg0012.tlg001:'+passage_component
		the_urn = CtsUrn.new(trailing_periods)
    fail('Should not have created URN with bad passage component inluding trailing period')
	rescue => e
		case e
		when RCiteException
			expect(e.message).to eq("Invalid URN syntax in passage component #{passage_component}: trailing period.")
		else
			fail('Should have thrown CiteException, not '+e.message)
		end
	end

	it should('throw an exception if there are leading periods in the range beginning part') do
		biff = 'urn:cts:greekLit:tlg0012.tlg001:.1-12'
		CtsUrn.new(biff)
    fail('Should not have created URN with bad range reference including leading period')
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid passage syntax in range beginning of '+biff)
		else
      fail('Should have thrown ArgumentError, not '+e.message)
		end
	end
  it should('throw an exception if there are trailing periods in the range beginning part') do
    boff = 'urn:cts:greekLit:tlg0012.tlg001:1.-12'
    CtsUrn.new(boff)
    fail('Should not have created URN with bad range reference including trailing period')
	rescue => e
		case e
		when RCiteException
			expect(e.message).to eq('Invalid URN: trailing period on range beginning reference 1.')
		else
      fail('Should have thrown CiteException, not '+e.message)
		end
	end

  it should('throw an exception if there are leading periods in the range ending part') do
		biff = 'urn:cts:greekLit:tlg0012.tlg001:1-.12'
    CtsUrn.new(biff)
    fail('Should not have created URN with bad range reference including leading period')
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: invalid passage syntax in range ending of '+biff)
		else
      fail('Should have thrown ArgumentError, not '+e.message)
		end
	end
  it should('throw an exception if there are trailing periods in the range ending part') do
		boff = 'urn:cts:greekLit:tlg0012.tlg001:1-12.'
    CtsUrn.new(boff)
    fail('Should not have created URN with bad range reference including trailing period')
	rescue => e
		case e
		when RCiteException
			expect(e.message).to eq('Invalid URN syntax in passage component 1-12.: trailing period.')
		else
      fail('Should have thrown CiteException, not '+e.message)
		end
	end

	it should('identify an empty passage as neither range nor node') do
		urn = CtsUrn.new('urn:cts:greekLit:tlg0012.tlg001:')
		expect(urn.is_range).to be false
		expect(urn.is_point).to be false
	end

	it should('throw an exception if the wrong number of components are given') do
		bad_urn_string = 'NOT_A_URN'
		u = CtsUrn.new(bad_urn_string)
    fail('Should not have made a URN from '+u)
	rescue => e
		case e
		when ArgumentError
			expect(e.message).to eq('requirement failed: Invalid URN syntax: too few components in '+bad_urn_string)
		else
			fail('Should have thrown an ArgumentError instead of '+e.inspect)
		end
	end

end
