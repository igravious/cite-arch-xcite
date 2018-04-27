
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

		##
		# A URN for a canonically citable text or passage of text.
		#
		# @constructor create a new [[CtsUrn]]
		# @param urnString String representation of [[CtsUrn]] validating
		# againt the CtsUrn specification
		#
		class CtsUrn
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
				# component is included.
				@components = urn_string.split(':')
				
				raise 'Invalid URN syntax: too few components in '+urn_string if @components.length <= 3
				raise 'Invalid URN syntax: too many components in '+urn_string if @components.length > 6

				# Required namespace component of the URN.
				@namespace = @components[2]
				# Required work component of the URN.
				@work_component = @components[3]
				# Array of dot-separate parts of the workComponent.
				@work_parts = @work_component.split('.')
				# Required textgroup part of work hierarchy.
				@text_group = @work_parts[0]

			end

			# Enumerated WorkLevel for this workComponent.
			def work_level
				@work_parts.length # :(
			end

			# Optional passage component of the [[CtsUrn]].
			def passage_component_option
				case @components.length
				when 5
					raise "Invalid URN syntax in passage component #{components[4]}: trailing period." if '.' == @components[4].chars.last
					@components[4]
				else
					nil
				end
			end
		end

	end

end
