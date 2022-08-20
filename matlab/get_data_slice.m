function data_out = get_data_slice(data_in, first_byte, number_of_bytes)
    data_temp_vec = zero(size(data_in, 1), number_of_bytes);

    for i = 1:number_of_bytes
        data_temp_vec(:, i) = (2^((i - 1) * 8)) * data_in;
        data_out = data_out + data_temp_vec(first_byte + i, i);
    end

end
