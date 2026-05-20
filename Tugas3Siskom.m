clc;
clear;
close all;

%% PARAMETER
jdata   = 1e5;      % jumlah bit
jsampel = 16;       % sampling per simbol
Tb      = 1;        % durasi bit
T       = 2*Tb;     % durasi simbol
fc      = 1/T;      % frekuensi carrier

%% DATA RANDOM
data = randi([0 1],1,jdata);

%% SERIAL TO PARALLEL
if mod(length(data),2) ~= 0
    data = [data 0];
end

bitPair = reshape(data,2,[])';

%% MAPPING 4-ARY ASK
% 01 -> 1
% 00 -> 3
% 10 -> 5
% 11 -> 7

symbol = zeros(1,size(bitPair,1));

for k = 1:size(bitPair,1)

    b1 = bitPair(k,1);
    b2 = bitPair(k,2);

    if b1==0 && b2==1
        symbol(k)=1;

    elseif b1==0 && b2==0
        symbol(k)=3;

    elseif b1==1 && b2==0
        symbol(k)=5;

    else
        symbol(k)=7;
    end
end

%% BASIS FUNCTION
t = 0:1/jsampel:T-1/jsampel;

psi = sqrt(2/T).*cos(2*pi*fc*t);

%% PEMBENTUKAN SINYAL TRANSMIT
tx = [];

for k = 1:length(symbol)

    s = symbol(k).*psi;

    tx = [tx s];
end

%% PLOT SINYAL TRANSMIT
figure;
plot(tx);
title('Sinyal QPSK / 4-ASK');
xlabel('Sample');
ylabel('Amplitude');
grid on;

%% FFT SPECTRUM
NFFT = 1024;

Xf = fft(tx,NFFT);

Xf = fftshift(Xf);

fs = jsampel/T;

f = (-NFFT/2:NFFT/2-1)*(fs/NFFT);

figure;
plot(f,abs(Xf));
title('Spektrum Frekuensi');
xlabel('Frekuensi (Hz)');
ylabel('|X(f)|');
grid on;

%% BER
EbNo_dB = 0:2:20;

BER = zeros(size(EbNo_dB));

for m = 1:length(EbNo_dB)

    % Tambah noise AWGN
    rx = awgn(tx,EbNo_dB(m),'measured');

    rxBit = [];

    index = 1;

    for k = 1:length(symbol)

        % Ambil 1 simbol
        r = rx(index:index+length(psi)-1);

        % Correlator detector
        z1 = sum(r.*psi)/jsampel;

        % Decision detector
        if z1 < 2
            b = [0 1];

        elseif z1 < 4
            b = [0 0];

        elseif z1 < 6
            b = [1 0];

        else
            b = [1 1];
        end

        % Simpan bit hasil deteksi
        rxBit = [rxBit b];

        index = index + length(psi);
    end

    % Hitung BER
    BER(m) = sum(data ~= rxBit)/length(data);

end

%% PLOT BER
figure;
semilogy(EbNo_dB,BER,'-o','LineWidth',2);
grid on;
title('BER 4-ary ASK');
xlabel('Eb/No (dB)');
ylabel('BER');

%% CONSTELLATION / LEVEL SIMBOL
figure;
stem(symbol,'filled');
title('Level Simbol 4-ary ASK');
xlabel('Simbol');
ylabel('Amplitude');
grid on;