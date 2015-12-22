#!/usr/bin/ruby

def read_file(file_name)
	byte_count = 0
	File.open(file_name, 'rb') do |file|
		while (buffer = file.read(4096)) do
			buffer.bytes.each do |byte|
				yield byte_count, byte
				byte_count += 1
			end
		end
	end
end

$last_byte_num = 0

def proc_follow_bytes(byte)
	if byte[7] == 1 && byte[6] == 0
		$last_byte_num -= 1
		return true
	end
	return false
end

def proc_head_byte(byte)
	return false if $last_byte_num > 0 || byte[6] == 0

	$last_byte_num = case
			when byte[5] == 0 # 110xxxxx
				1
			when byte[4] == 0 # 1110xxxx
				2
			when byte[3] == 0 # 11110xxx
				3
			when byte[2] == 0 # 111110xx
				4
			when byte[1] == 0 # 1111110x
				5
			else return false
			end
	return true
end

def proc_ascii_char
	return $last_byte_num == 0
end

read_file(ARGV[0]) do |count, byte|
	if $last_byte_num > 0
		ret = proc_follow_bytes(byte)
	elsif byte[7] == 1
		ret = proc_head_byte(byte)
	else
		ret = proc_ascii_char()
	end
	if ! ret
		abort("Check failed at position: #{count}")
	end
end

puts "Check succeed!"
