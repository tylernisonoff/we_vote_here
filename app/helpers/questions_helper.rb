module QuestionsHelper

	require 'set'

	# with probability 1/2, returns a random number between min and max
	# with probability 1/2, returns a random number between -min and -max
	def new_random (min, max)
	  return (rand * (max-min) + min)
	end


	def complete(winner_hash, n)
	    num_comparisons = 0
	    winner_hash.each do |choice_id, defeated|
	        num_comparisons = num_comparisons + defeated.size()
	    end

	    if num_comparisons == ((n-1)*n)/2
	      return true
	    else
	      return false
	    end
	end
end
