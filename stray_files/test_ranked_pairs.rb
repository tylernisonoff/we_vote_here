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

def test_ranked_pairs(nn)
	@mov = Hash.new
	max = 100
	n = nn

	time_start = Time.now

	# printer = 0: print nothing
	# printer = 1: print "X beats Y"
	# printer = -1: print "Y lost to X"
	printer = 1

	(1..n).each do |i|
		unless @mov[i]
				@mov[i] = Hash.new
		end
		(1..n).each do |j|
			if i > j
				r = new_random(-1*max, max)
				@mov[i][j] = r
				@mov[j][i] = -1*r
			elsif i == j
				@mov[i][j] = 0
			end
		end
	end

	#### INSERT RANKED PAIRS CODE NOW

	@mov_list = Array.new
	@mov.each do |i, hash|
		hash.each do |j, margin|
			if i > j
				if margin >= 0
					@mov_list.push([margin, i, j])
				else
					@mov_list.push([-1*margin, j, i])
				end
			end
		end
	end

	@mov_list.sort! { |a,b| a[0] <=> b[0] }

	winner_hash = Hash.new
	# for choice id "i",
	# winner_hash[i] stores the set of choices who i defeated

	loser_hash = Hash.new
	# for choice id "i",
	# loser_hash[i] stores the set of choices who defeated i

	until complete(winner_hash, n)
		if @mov_list.size == 0
			break
		end
		
		# select the next strongest inequality
		strongest_inequality = @mov_list.pop
		
		margin = strongest_inequality[0]
		winner = strongest_inequality[1]
		loser = strongest_inequality[2]

		added = Set.new
		before_merge = Set.new

		[winner, loser].each do |i|
			# If winner_hash[choice] does not exist,
			# create it as an empty set
			[winner_hash, loser_hash].each do |hash|
				unless hash[i]
					hash[i] = Set.new
				end
			end
			# unless winner_hash[i]
			#   winner_hash[i] = Set.new
			# end
			# unless loser_hash[i]
			#   loser_hash[i] = Set.new
			# end
		end

		if winner_hash[loser].include?(winner)
			# if this inequality is inconsistent with
			# previous inequalities, ignore this inequality
			next
		else
			unless printer == 0
				print "\nWinner: #{winner}\nLoser: #{loser}\nMargin: #{margin}\n"
			end

			# add the loser to set of those the winner beats
			winner_hash[winner].add(loser)
			if printer == 1
				print "#{winner} beat #{loser}\n"
			end

			# add the winner to the set of those the loser loses to
			loser_hash[loser].add(winner)
			if printer == -1
				print "#{loser} lost to #{winner}\n"
			end


			# add the set of choices the loser beat
			# to the set of choices the winner beat
			before_merge = Set.new(winner_hash[winner])
			winner_hash[winner].merge(winner_hash[loser])
			
			if printer == 1  
				added = winner_hash[winner] - before_merge
				unless added.empty?
					added.each do |lost_to_loser|
						print "#{winner} beat #{lost_to_loser}\n"
					end
				end
			end

			# add the set of choices that beat the winner
			# to the set of choices the loser has lost to.
			before_merge = Set.new(loser_hash[loser])
			loser_hash[loser].merge(loser_hash[winner])
			
			if printer == -1
				added = loser_hash[loser] - before_merge
				unless added.empty?
					added.each do |beat_winner|
						print "#{loser} lost to #{beat_winner}\n"
					end
				end
			end

			# for each choice, "L" that the loser has beaten,
			# add the set of choices that has beaten the loser
			# to the set of choices that has beaten "L"
			winner_hash[loser].each do |lost_to_loser|
				# print "Recall: #{loser} beat #{lost_to_loser}\n"
				before_merge = Set.new(loser_hash[lost_to_loser])
				loser_hash[lost_to_loser].merge(loser_hash[loser])
				if print == -1
					added = loser_hash[lost_to_loser] - before_merge
					unless added.empty?
						added.each do |beat_loser|
							print "#{lost_to_loser} lost to #{beat_loser}\n"
						end
					end
				end
			end

			# for each choice, "W", that beat the winner,
			# add the set of choices that the winner has beaten
			# to the set of choices that W beat.
			loser_hash[winner].each do |beat_winner|
				# print "Recall: #{winner} lost to #{beat_winner}\n"
				before_merge = Set.new(winner_hash[beat_winner])
				winner_hash[beat_winner].merge(winner_hash[winner])
				if printer == 1
					added = winner_hash[beat_winner] - before_merge
					unless added.empty?
						added.each do |lost_to_winner|
							print "#{beat_winner} beat #{lost_to_winner}\n"
						end
					end
				end
			end

			# print "\n\n"

			 # print "\n"
		end
	end

		result_array = Array.new
		# the winner is the choice who beats the most others

		winner_hash.each do |choice, set|
			if choice > 0
				result_array.push([choice, set.size()])
			end
		end

		# find out who's on top
		result_array.sort! { |a,b| b[1] <=> a[1] }

		
	#### END RANKED PAIRS CODE NOW

		# TEST #1
		# print "\n\n\nBEGIN TEST #1\n\n\n"
		# result_array.each_with_index do |result, index|
		# 	puts "Position #{index}: #{result[0]}"
		# end
		# print "\n\n\nEND TEST #1\n\n\n"

		# print "\n\n\nBEGIN TEST #2\n"
		# winner_hash.each do |choice, set|
		#   print "#{choice} beats ["
		#   set.each do |e|
		#     print "#{e}, "
		#   end
		#   print "]\n"
		# end
		# print "\nEND TEST #2\n\n\n"


		print "\n-------ADJUSTED MARGIN OF VICTORY MATRIX------\n\n"
		result_array.each do |result|
		  print "#{result[0]}: ["
		  @mov[result[0]].each do |key, value|
		    print "#{key}: "
		    printf('%.0f, ', value)
		  end
		  print "]\n"
		end
		print "\n\n"

		time_end = Time.now

		time_of_algo = time_end - time_start

		# puts "Time of Algo for n = #{n}: #{time_of_algo}"
		# puts "\nn = #{n}\nt = #{time_of_algo}\n"

end

test_ranked_pairs(5)