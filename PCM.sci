// Custom function to convert decimal to binary string with fixed bit depth
function bin_str=dec2bin_custom(val, bit_depth)
    bin_str = "";
    for i = bit_depth-1:-1:0
        bin_str = bin_str + string(floor(val / 2^i));
        val = modulo(val, 2^i);
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

// ======= PART 4: ADD AWGN NOISE =========
snr = 10^(snr_db / 10);
noise = rand(1, length(binary_stream), "normal") * sqrt(0.5/snr);
noisy_binary_stream = binary_stream + noise;

// Plot Noisy PCM Encoded Signal
scf(2); plot(noisy_binary_stream, 'r');
xlabel("Bit Index"); ylabel("Bit Value");
title("Noisy PCM Encoded Bit Stream");
xgrid();

// ======= PART 5: PCM DECODING =========
recovered_values = [];
for i = 1:bit_depth:length(noisy_binary_stream) - bit_depth + 1
    bits = noisy_binary_stream(i:i+bit_depth-1);
    bits = round(bits); // Round to nearest integer (0 or 1)
    bits(bits > 1) = 1; // Ensure all bits are either 0 or 1
    bits(bits < 0) = 0;
    bit_str = strcat(string(bits));
    val = bin2dec(bit_str);
    temp = val * (max_temp - min_temp) / (2^bit_depth - 1) + min_temp;
    recovered_values = [recovered_values, temp];
end

// ======= PART 6: BER CALCULATION AFTER TRANSMISSION =========
minlen = min(length(binary_stream), length(noisy_binary_stream));
bit_errors_after_transmission = sum(binary_stream(1:minlen) <> round(noisy_binary_stream(1:minlen)));
ber_after_transmission = bit_errors_after_transmission / minlen;
disp("Bit Error Rate (BER) after Transmission = " + string(ber_after_transmission));

// ======= PART 7: MSE CALCULATION =========
mse = mean((sensor_data(1:length(recovered_values)) - recovered_values).^2);
disp("Mean Squared Error (MSE) = " + string(mse));

// ======= PART 8: FINAL COMPARISON PLOT =========
scf(3);
plot(sensor_data(1:length(recovered_values)), 'b-'); // Original Signal
plot(recovered_values, 'm--'); // Recovered Signal
legend(["Original Signal", "Reconstructed Signal"]);
xlabel("Sample Index"); ylabel("Temperature (°C)");
title("Original vs. Recovered Sensor Data");
xgrid();

// ======= PART 9: PLOT RECOVERED SIGNAL =========
scf(4);
plot(recovered_values, 'r--'); // Recovered Signal
xlabel("Sample Index"); ylabel("Temperature (°C)");
title("Recovered Sensor Data");
xgrid();

// ======= PART 10: EXTRACT AND DISPLAY 10 SAMPLES =========
num_samples_to_compare = 10;
sample_indices = round(linspace(1, length(sensor_data), num_samples_to_compare));
original_samples = sensor_data(sample_indices);
recovered_samples = recovered_values(sample_indices);

disp("Sample Index | Original Data | Recovered Data");
disp("-------------|---------------|---------------");
for i = 1:num_samples_to_compare
    disp(string(sample_indices(i)) + "            | " + string(original_samples(i)) + "          | " + string(recovered_samples(i)));
end

// ======= PART 11: BER COMPARISON =========
disp("BER Comparison:");
disp("---------------");
disp("BER before Transmission: " + string(ber_before_transmission));
disp("BER after Transmission: " + string(ber_after_transmission));

disp("Simulation Completed!");
