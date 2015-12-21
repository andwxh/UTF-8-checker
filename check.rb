#!/usr/bin/ruby

def read_file(file_name)
	bit_count = 0
	File.open(file_name, 'rb') do |file|
		while (buffer = file.read(1)) do
			yield bit_count, buffer.unpack('B*')[0]
			bit_count += 1
		end
	end
end

$last_byte_num = 0

def proc_follow_bytes(bstr)
	if bstr.start_with?("10")
		$last_byte_num -= 1
		return true
	end
	return false
end

def proc_head_byte(bstr)
	if $last_byte_num > 0
		return false
	end
	$last_byte_num = case
			when bstr.start_with?('110')
				1
			when bstr.start_with?('1110')
				2
			when bstr.start_with?('11110')
				3
			when bstr.start_with?('111110')
				4
			when bstr.start_with?('1111110')
				5
			else return false
			end
	return true
end

def proc_ascii_char
	return $last_byte_num == 0
end

read_file(ARGV[0]) do |count, bstr|
	if $last_byte_num > 0
		ret = proc_follow_bytes(bstr)
	elsif bstr.start_with?("1")
		ret = proc_head_byte(bstr)
	else
		ret = proc_ascii_char()
	end
	if ! ret
		abort("Check failed at position: #{count}")
	end
end

puts "Check succeed!"
