// Custom function to convert decimal to binary string with fixed bit depth
function bin_str=dec2bin_custom(val, bit_depth)
    bin_str = "";
    for i = bit_depth-1:-1:0
        bin_str = bin_str + string(floor(val / 2^i));
        val = modulo(val, 2^i);
    end
endfunction

// Function to perform QPSK modulation
function symbols=qpsk_modulation(bitstream)
    symbols = [];
    for i = 1:2:length(bitstream)
        if bitstream(i) == 0 & bitstream(i+1) == 0 then
            symbols = [symbols, 1 + %i];
        elseif bitstream(i) == 0 & bitstream(i+1) == 1 then
            symbols = [symbols, -1 + %i];
        elseif bitstream(i) == 1 & bitstream(i+1) == 0 then
            symbols = [symbols, 1 - %i];
        else
            symbols = [symbols, -1 - %i];
        end
    end
endfunction

// Function to perform QPSK demodulation
function bitstream=qpsk_demodulation(symbols)
    bitstream = [];
    for i = 1:length(symbols)
        if real(symbols(i)) > 0 & imag(symbols(i)) > 0 then
            bitstream = [bitstream, 0, 0];
        elseif real(symbols(i)) < 0 & imag(symbols(i)) > 0 then
            bitstream = [bitstream, 0, 1];
        elseif real(symbols(i)) > 0 & imag(symbols(i)) < 0 then
            bitstream = [bitstream, 1, 0];
        else
            bitstream = [bitstream, 1, 1];
        end
    end
endfunction

// ======= PART 1: SENSOR DATA GENERATION =========
num_samples = 1000;           // Number of temperature samples
bit_depth = 8;                // Bits per sample
snr_db = 6;                   // Signal-to-noise ratio in dB

sensor_data = 100 * rand(1, num_samples); // Temperature range: 0°C to 100°C

// Plot original sensor data
scf(0); plot(sensor_data, 'g');
xlabel("Sample Index"); ylabel("Temperature (°C)");
title("Original Sensor Temperature Data");
xgrid();

// ======= PART 2: PCM ENCODING (8-bit Quantization) =========
min_temp = 0;
max_temp = 100;
quantized_data = round((sensor_data - min_temp) * (2^bit_depth - 1) / (max_temp - min_temp));

// Plot 8-bit Quantization
scf(1); plot(quantized_data, 'b');
xlabel("Sample Index"); ylabel("Quantized Levels");
title("8-Bit Quantization of Sensor Data");
xgrid();

// Convert to bitstream correctly
binary_stream = [];
for i = 1:num_samples
    bin_str = dec2bin_custom(quantized_data(i), bit_depth);
    binary_stream = [binary_stream, ascii(bin_str) - ascii('0')];
end

// ======= PART 3: BER CALCULATION BEFORE TRANSMISSION =========
// Assuming original binary stream is the quantized data converted to binary
original_binary_stream = binary_stream; // This is the same as binary_stream in this context

// Calculate BER before transmission
bit_errors_before_transmission = sum(original_binary_stream <> binary_stream);
ber_before_transmission = bit_errors_before_transmission / length(original_binary_stream);
disp("Bit Error Rate (BER) before Transmission = " + string(ber_before_transmission));

// ======= PART 4: QPSK MODULATION =========
qpsk_symbols = qpsk_modulation(binary_stream);

// ======= PART 5: ADD AWGN NOISE =========
snr = 10^(snr_db / 10);
noise_power = 1 / (2 * snr);
noise = sqrt(noise_power) * (rand(1, length(qpsk_symbols), "normal") + %i * rand(1, length(qpsk_symbols), "normal"));
noisy_qpsk_symbols = qpsk_symbols + noise;

// Plot Noisy QPSK Encoded Signal
scf(2); plot(real(noisy_qpsk_symbols), imag(noisy_qpsk_symbols), 'r*');
xlabel("In-phase"); ylabel("Quadrature");
title("Noisy QPSK Encoded Symbols");
xgrid();

// ======= PART 6: QPSK DEMODULATION =========
recovered_binary_stream = qpsk_demodulation(noisy_qpsk_symbols);

// ======= PART 7: PCM DECODING =========
recovered_values = [];
for i = 1:bit_depth:length(recovered_binary_stream) - bit_depth + 1
    bits = recovered_binary_stream(i:i+bit_depth-1);
    bit_str = strcat(string(bits));
    val = bin2dec(bit_str);
    temp = val * (max_temp - min_temp) / (2^bit_depth - 1) + min_temp;
    recovered_values = [recovered_values, temp];
end

// ======= PART 8: BER CALCULATION AFTER TRANSMISSION =========
minlen = min(length(binary_stream), length(recovered_binary_stream));
bit_errors_after_transmission = sum(binary_stream(1:minlen) <> recovered_binary_stream(1:minlen));
ber_after_transmission = bit_errors_after_transmission / minlen;
disp("Bit Error Rate (BER) after Transmission = " + string(ber_after_transmission));

// ======= PART 9: MSE CALCULATION =========
mse = mean((sensor_data(1:length(recovered_values)) - recovered_values).^2);
disp("Mean Squared Error (MSE) = " + string(mse));

// ======= PART 10: FINAL COMPARISON PLOT =========
scf(3);
plot(sensor_data(1:length(recovered_values)), 'b-'); // Original Signal
plot(recovered_values, 'm--'); // Recovered Signal
legend(["Original Signal", "Reconstructed Signal"]);
xlabel("Sample Index"); ylabel("Temperature (°C)");
title("Original vs. Recovered Sensor Data");
xgrid();

// ======= PART 11: PLOT RECOVERED SIGNAL =========
scf(4);
plot(recovered_values, 'r--'); // Recovered Signal
xlabel("Sample Index"); ylabel("Temperature (°C)");
title("Recovered Sensor Data");
xgrid();

// ======= PART 12: EXTRACT AND DISPLAY 10 SAMPLES =========
num_samples_to_compare = 10;
sample_indices = round(linspace(1, length(sensor_data), num_samples_to_compare));
original_samples = sensor_data(sample_indices);
recovered_samples = recovered_values(sample_indices);

disp("Sample Index | Original Data | Recovered Data");
disp("-------------|---------------|---------------");
for i = 1:num_samples_to_compare
    disp(string(sample_indices(i)) + "            | " + string(original_samples(i)) + "          | " + string(recovered_samples(i)));
end

// ======= PART 13: BER COMPARISON =========
disp("BER Comparison:");
disp("---------------");
disp("BER before Transmission: " + string(ber_before_transmission));
disp("BER after Transmission: " + string(ber_after_transmission));

disp("Simulation Completed!");
