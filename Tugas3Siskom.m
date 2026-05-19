%% BER vs EbNo
EbNo_dB = 0:2:20;
BER = zeros(size(EbNo_dB));

for m = 1:length(EbNo_dB)

    % Tambah noise AWGN
    rx = awgn(tx,EbNo_dB(m),'measured');

    rxBit = [];

    index = 1;

    for k = 1:length(symbol)

        r = rx(index:index+length(psi)-1);

        % correlator
        z1 = sum(r.*psi)/jsampel;

        % detector
        if z1 < 2
            b = [0 1];

        elseif z1 < 4
            b = [0 0];

        elseif z1 < 6
            b = [1 0];

        else
            b = [1 1];
        end

        rxBit = [rxBit b];

        index = index + length(psi);
    end

    % hitung BER
    BER(m) = sum(data ~= rxBit)/length(data);

end

%% Plot BER
figure;
semilogy(EbNo_dB,BER,'-o','LineWidth',2);
grid on;
xlabel('Eb/No (dB)');
ylabel('BER');
title('BER QPSK');