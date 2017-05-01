function [out_SAD, SAD_array, output_image] = logarithm(block_size, search_range, ref_image, T)

p = search_range;
out_SAD = 0.0;
output_image = zeros(320, 640, 3);
SAD_array = zeros(40, 80);

for i_target = 1:block_size:320				% for target image
	for j_target = 1:block_size:640
		T_block = T(i_target:i_target+block_size-1, j_target:j_target+block_size-1, :);			
		
		if(i_target-p < 1)
			up = 1;
		else
			up = i_target-p;
		end
		
		if(j_target-p < 1)
			left = 1;
		else
			left = j_target-p;
		end
		
		if(i_target+p > 320-block_size+1)
			buttom = 320-block_size+1;
		else
			buttom = i_target+p;
		end
		
		if(j_target+p > 640-block_size+1)
			right = 640-block_size+1;
		else
			right = j_target+p;
		end
		
		SAD_min = 10000000.0;
		loop = true;
		i_ref = i_target;
		j_ref = j_target;
		n = p/2;
		while(loop)
			if(n >= 1)
				next = 0;
				SAD = sum(sum(sum(abs( T_block-ref_image(i_ref:i_ref+block_size-1, j_ref:j_ref+block_size-1, :) ))));
				if ( SAD < SAD_min )
					SAD_min = SAD;
					output_image(i_target:i_target+block_size-1, j_target:j_target+block_size-1, :) = ref_image(i_ref:i_ref+block_size-1, j_ref:j_ref+block_size-1, :);
					next = 0;
				end
				if( i_ref + n <= buttom )
					SAD = sum(sum(sum(abs( T_block-ref_image(i_ref+n:i_ref+n+block_size-1, j_ref:j_ref+block_size-1, :) ))));
					if ( SAD < SAD_min )
						SAD_min = SAD;
						output_image(i_target:i_target+block_size-1, j_target:j_target+block_size-1, :) = ref_image(i_ref+n:i_ref+n+block_size-1, j_ref:j_ref+block_size-1, :);
						next = 1;
					end
				end
				if( i_ref - n >= up )
					SAD = sum(sum(sum(abs( T_block-ref_image(i_ref-n:i_ref-n+block_size-1, j_ref:j_ref+block_size-1, :) ))));
					if ( SAD < SAD_min )
						SAD_min = SAD;
						output_image(i_target:i_target+block_size-1, j_target:j_target+block_size-1, :) = ref_image(i_ref-n:i_ref-n+block_size-1, j_ref:j_ref+block_size-1, :);
						next = -1;
					end
				end
				if( j_ref + n <= right )
					SAD = sum(sum(sum(abs( T_block-ref_image(i_ref:i_ref+block_size-1, j_ref+n:j_ref+n+block_size-1, :) ))));
					if ( SAD < SAD_min )
						SAD_min = SAD;
						output_image(i_target:i_target+block_size-1, j_target:j_target+block_size-1, :) = ref_image(i_ref:i_ref+block_size-1, j_ref+n:j_ref+n+block_size-1, :);
						next = 2;
					end
				end
				if( j_ref - n >= left )
					SAD = sum(sum(sum(abs( T_block-ref_image(i_ref:i_ref+block_size-1, j_ref-n:j_ref-n+block_size-1, :) ))));
					if ( SAD < SAD_min )
						SAD_min = SAD;
						output_image(i_target:i_target+block_size-1, j_target:j_target+block_size-1, :) = ref_image(i_ref:i_ref+block_size-1, j_ref-n:j_ref-n+block_size-1, :);
						next = -2;
					end
				end
				
				if(next == 0)
					n = n/2;
				elseif(next == 1)
					i_ref = i_ref + n;
				elseif(next == -1)
					i_ref = i_ref - n;
				elseif(next == 2)
					j_ref = j_ref + n;
				elseif(next == -2)
					j_ref = j_ref - n;
				end
			else
				for i = i_ref-1:i_ref+1
					if(i_ref+1 > right)
						break;
					end
					for j = j_ref-1:j_ref+1
						if(j_ref+1 > buttom)
							break;
						end
						
						SAD = sum(sum(sum(abs( T_block-ref_image(i_ref:i_ref+block_size-1, j_ref:j_ref+block_size-1, :) ))));
						if ( SAD < SAD_min )
							SAD_min = SAD;
							output_image(i_target:i_target+block_size-1, j_target:j_target+block_size-1, :) = ref_image(i_ref:i_ref+block_size-1, j_ref:j_ref+block_size-1, :);
						end
					end
				end
				loop = false;
			end
		end
		SAD_array(floor(i_target/block_size)+1, floor(j_target/block_size)+1) = SAD_min;
		out_SAD = out_SAD + SAD_min;
	end
end