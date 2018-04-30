
# I'm thinking
#   RCite::Cite
#   RCite::CtsUrn – canonical text services
#   Where does OHCO2 go?

require 'pry'

module Xcite

	module Cite

		# TODO: use this functionality?
		# This library adds URN scheme support for standard bundled URI library described in RFC 4122.
		# https://rubygems.org/gems/uri-urn
		require 'uri/urn'

		module WorkLevel
			TextGroup = 1
			Work = 2
			Version = 3
			Exemplar = 4
		end

		class RCiteException < StandardError
		end

		def insist(str)
			raise ::ArgumentError, "requirement failed: #{str}"
		end

		##
		# A URN for a canonically citable text or passage of text.
		#
		# @constructor create a new [[CtsUrn]]
		# @param urnString String representation of [[CtsUrn]] validating
		# againt the CtsUrn specification
		#
		class CtsUrn
			attr_accessor :urn_string
			attr_accessor :components
			attr_accessor :namespace
			attr_accessor :work_component
			attr_accessor :work_parts
			attr_accessor :text_group

			def initialize(urn_string)
				# Array of top-level, colon-delimited components.
				#
				# The Array will have 4 elements if the optional passage
				# component is omitted;  if will have 5 elements if the passage
				# component is included
				@urn_string = urn_string
				@components = @urn_string.split(':')
			
				insist 'Invalid URN syntax: too few components in '+@urn_string unless @components.length > 3
				insist 'Invalid URN syntax: too many components in '+@urn_string unless @components.length < 6

				# Required namespace component of the URN.
				@namespace = @components[2]
				# Required work component of the URN.
				@work_component = @components[3]
				# Array of dot-separate parts of the workComponent.
				@work_parts = @work_component.split('.')
				# Required textgroup part of work hierarchy.
				@text_group = @work_parts[0]

				# Optional single passage node.
				@passage_node_option = ((1 == passage_parts.length) ? NullableString.new(passage_parts[0]) : None)

				fully_valid
			end

			# Enumerated WorkLevel for this workComponent.
			def work_level
				@work_parts.length # :(
			end

			class NullableString < BasicObject
				attr_accessor :target
				def initialize(object)
					if object.nil? or object.is_a?(::String)
						@target = object
					else
						raise ::ArgumentError, "Bad object: #{object.inspect}"
					end
				end

				def method_missing(method_name, *args, &block)
					# check if a String method
					if @target.respond_to?(method_name)
						@target.send(method_name, *args, &block)
					else
						::Kernel.puts "NoMethodError :( (undefined method `#{method_name}' for #{@target.inspect})"
						::Kernel.exit
					end
				end

				def split(thingy)
					if @target.nil?
						[]
					else
						@target.split(thingy)
					end
				end

				def say
					if @target.nil?
						::Kernel.puts "Nullable (nil)"
					else
						::Kernel.puts "Nullable '#{@target}'"
					end
				end

				def get(reject, urn=nil)
					if @target.nil?
						# method(:puts).owner
						::Kernel.puts "should never get here?\n#{urn.inspect}"
						::Kernel.exit
						# ::Kernel.raise "Should never get here."
						::Kernel.raise RCiteException, reject
					else
						@target
					end
				end
			end

			None = NullableString.new(nil)

			# Optional passage component of the [[CtsUrn]].
			def passage_component_option
				case @components.length
				when 5
					# choose a more specific exception
					raise RCiteException, "Invalid URN syntax in passage component #{components[4]}: trailing period." if '.' == @components[4].chars.last
					NullableString.new(@components[4])
				else
					None
				end
			end

			# String value of optional passage component of the URN.
			def passage_component
				passage_component_option.get('No passage component defined in ', self)
			end

			# True if URN's syntax for required components is valid.
			def component_syntax_ok
				case @components.length
				when 5
					true
				when 4
					':' == @urn_string.chars.last
				else
					false
				end
			end

			##
			# Array of hyphen-separated parts of the passageComponent.
			#
			# The Array will contain 0 elements if passageComponent is empty,
			# 1 element if the passageComponent is a node reference, and
			# 2 elements if the passageComponent is a range reference.
			#
			def passage_parts
				passage_component_option.split('-')
			end

			def passage_node
				@passage_node_option.get('No individual node defined in ', self)
			end

			# Array splitting optional single passage node into reference and extended reference.
			def passage_node_parts
				@passage_node_option.split('@')
			end

			# True if URN's syntax for optional passage component is valid.
			def passage_syntax_ok
				# puts "… #{passage_parts.length}"
				case passage_parts.length
				when 0
					passage_component_option.nil? ? true : false
				when 1
					passage_component.match('-').nil? ? true : false
				when 2
					!range_begin.empty? and !range_end.empty? # https://www.techotopia.com/index.php/Ruby_Operator_Precedence
				else
					raise RCiteException, 'invalid URN string: more than two elements in range '+passage_component
				end
			end

			# First part of an optional range expression in optional passage component.
			def range_begin_option
				if passage_parts.length > 1
					part = passage_parts.first
					l = part.chars.last
					if l.nil?
						raise RCiteException, 'No range beginning defined in '+@urn_string
					elsif '.' == l
						raise RCiteException, 'Invalid URN: trailing period on range beginning reference '+part
					else
						NullableString.new(part)
					end
				else
					None
				end	
			end
			
			# String value of first part of an optional range expression in optional passage component.
			def range_begin
				# range_begin_option.say
				# FIXME: pass ArgumentError or raise ArgumentError in range_begin_option
				range_begin_option.get('No range beginning defined in '+@urn_string, self)
			end

			# Array splitting first part of optional range expression into reference and extended reference.
			def range_begin_parts
				range_begin_option.split('@')
			end

			# Second part of an optional range expression in optional passage component.
			def range_end_option
				if passage_parts.length > 1
					part = passage_parts.last
					l = part.chars.last
					if l.nil?
						raise RCiteException, 'No range ending defined in '+@urn_string
					elsif '.' == part.chars.last
						raise RCiteException, 'Invalid URN: trailing period on range beginning reference '+part
					else
						NullableString.new(part)
					end
				else
					None
				end	
			end
			
			# String value of first part of an optional range expression in optional passage component.
			def range_end
				range_end_option.get('No range ending defined in ', self)
			end

			# Array splitting first part of optional range expression into reference and extended reference.
			def range_end_parts
				range_end_option.split('@')
			end

			# True if the passage component refers to a range.*/
			def is_range
				ns = passage_component_option
				if ns.nil?
					false
				else
					!ns.get(nil, self).match('-').nil?
				end
			end
			# True if the URN refers to a point (leaf node or containing node).*/
			def is_point
				ns = passage_component_option
				if ns.nil?
					false
				else
					s = ns.get(nil, self)
					s.match('-').nil? and !s.empty?
				end
			end

			##
			# True if value submitted to construct this [[CtsUrn]] complies
			# fully with the CtsUrn specification.
			#
			def fully_valid
				insist "invalid URN syntax: #{@urn_string}. First component must be 'urn'." unless 'urn' == components.first
				insist "invalid URN syntax: #{@urn_string}. Second component must be 'cts'." unless 'cts' == components[1]
				insist "invalid URN syntax: #{@urn_string}. Wrong number of components." unless component_syntax_ok
				insist 'invalid URN syntax. Too many parts in work component '+@work_component unless @work_parts.length < 5
				insist 'invalid URN syntax. Error in passage component '+passage_component unless passage_syntax_ok

				insist 'invalid work syntax in '+@urn_string if @work_parts.any? {|p| p.empty?}
				insist 'invalid passage syntax in '+@urn_string if passage_parts.any? {|p| p.empty?}
				insist 'invalid passage syntax in passage node '+@urn_string if passage_node_parts.any? {|p| p.empty?}
				insist 'invalid passage syntax in range beginning '+@urn_string if range_begin_parts.any? {|p| p.empty?}
				insist 'invalid passage syntax in range ending '+@urn_string if range_end_parts.any? {|p| p.empty?}

				pco = passage_component_option
				#pco.say
				if pco.nil? # TODO: need to overload ===() to match None for case
					true
				else
					if is_range
						from_parts = range_begin.split('.')
						insist 'invalid passage syntax in range beginning of '+@urn_string if from_parts.any? {|p| p.empty?}
						to_parts = range_end.split('.')
						insist 'invalid passage syntax in range ending of '+@urn_string if to_parts.any? {|p| p.empty?}
					else
						node_parts = passage_node.split('.')
						insist 'invalid passage syntax in '+@urn_string if node_parts.any? {|p| p.empty?}
					end
				end
				
				if 5 == @components.length
					if ':' == @urn_string.chars.last
						raise RCiteException, 'Invalid URN syntax: trailing colon in '+@urn_string
					else
						true
					end
				else
					true
				end
			end
		end

	end

end
