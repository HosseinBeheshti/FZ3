function data_out = get_data_slice(data_in, first_byte, number_of_bytes)
    data_temp_vec = zeros(length(first_byte), number_of_bytes);
    data_out = zeros(length(first_byte), 1);

    for i = 1:number_of_bytes
        data_temp_vec(:, i) = (2^((i - 1) * 8)) * data_in(first_byte + i - 1);
        data_out = data_out + data_temp_vec(:, i);
    end

end
