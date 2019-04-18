% M-QAM Simulation by Natalie Kim and Michael Diaz

% This script simulates the transmission of an image, student.jpg, through
% an AWGN channel using M-QAM. User may specify the value of M, the
% signal-to-noise ratio, and whether to use binary- or gray-coded symbol
% mappings. Three functions are used: transmitter, channel, and receiver.

% After each transmission, a figure will display side-by-side the original
% image and the received image, as well as a constellation map of the 
% received signal symbols. The user will then be given the option of
% running the simulation again with a different SNR value, or ending the
% program. Ending the program will automatically display a graph of the
% probability of error versus SNRs tested in the run.

% Each transmission should take 10 seconds or less

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store SNR and BER values to be graphed later
EbNoarray = [];
BERarray = [];
SERarray = [];

% User specifies M-level and mapping type
prompt = 'Enter the M-level: ';
M = input(prompt);
k = log2(M);
prompt = 'Do you want to use gray or binary mapping? Enter g or b: ';
str = input(prompt,'s');
useGray = strcmpi(str,'g');

run = true;

while run
    % User specifies Eb/No
    prompt = 'Enter Eb/No, the ratio of bit energy-to-noise power spectral density, in dB: ';
    EbNo = input(prompt);

    % Load image into matrix of RGB values
    I = imread("student.jpg");
    % Determine dimensions of image in pixels
    imageWidth = size(I(1,:,1)); %x
    imageWidth = imageWidth(2);
    imageLength = size(I(:,1,1)); %y
    imageLength = imageLength(1);

    % sentBitStream - the original bit vector before noise is added
    % sentSymbols - the vector of symbols to be sent
    % sentSignal - the modulated signal before noise is added
    [sentBitStream,sentSymbols,sentSignal] = transmitter(I,imageWidth,imageLength,M,useGray);

    % Send the signal through an AWGN channel
    % The equation for SNR was found at https://www.mathworks.com/help/comm/gs/compute-ber-for-a-qam-system-with-awgn-using-matlab.html
    SNR = EbNo + 10*log10(k);
    receivedSignal = channel(sentSignal,SNR);

    % Display constellation diagram of the received signal
    sPlotFig = scatterplot(receivedSignal,1,0,'g.');
    hold on
    scatterplot(sentSignal,1,0,'k*',sPlotFig)

    % receivedBitStream - the bit vector after demodulation
    % receivedSymbols - the vector of received symbols
    % receivedImage - RGB matrix of the reconstructed image
    [receivedBitStream,receivedSymbols,receivedImage] = receiver(receivedSignal,imageWidth,imageLength,M,useGray);

    % Display the original image and the received image
    figure()
    subplot(1,2,1);
    imshow(I);
    title("Sent");
    subplot(1,2,2);
    imshow(receivedImage);
    title("Received");

    % Determine the SER
    symbolerrors = 0;
    streamLength = size(sentSymbols);
    streamLength = streamLength(1);
    for i=1:streamLength
        if sentSymbols(i) ~= receivedSymbols(i)
            symbolerrors = symbolerrors + 1;
        end
    end
    SER = symbolerrors/streamLength;
    
    % Determine the BER
    biterrors = 0;
    bitstreamLength = size(sentBitStream);
    bitstreamLength = bitstreamLength(2);
    for i=1:bitstreamLength
        if sentBitStream(i) ~= receivedBitStream(i)
            biterrors = biterrors + 1;
        end
    end
    BER = biterrors/bitstreamLength;
    
    if useGray
        fprintf("For "+M+"-QAM using gray mapping with Eb/No of "+EbNo+"db,\n the observed bit error rate is " + 100*BER + " percent, based on " + biterrors + " errors.");
    else
        fprintf("For "+M+"-QAM using binary mapping with Eb/No of "+EbNo+"db,\n the observed bit error rate is " + 100*BER + " percent, based on " + biterrors + " errors.");
    end
    fprintf("\n");
    
    
    % Add EbNo, SER, and BER to master array in ascending order of EbNo
    if length(EbNoarray)<1 || EbNo>EbNoarray(length(EbNoarray))
        EbNoarray = horzcat(EbNoarray,EbNo);
        BERarray = horzcat(BERarray,BER);
        SERarray = horzcat(SERarray,SER);
    elseif EbNo<EbNoarray(1)
        EbNoarray = horzcat(EbNo,EbNoarray);
        BERarray = horzcat(BER,BERarray);
        SERarray = horzcat(SER,SERarray);
    else
        for i=2:length(EbNoarray)
            if EbNo<EbNoarray(i)
                EbNoarray = horzcat(EbNoarray(1:i-1),EbNo,EbNoarray(i:length(EbNoarray)));
                BERarray = horzcat(BERarray(1:i-1),BER,BERarray(i:length(BERarray)));
                SERarray = horzcat(SERarray(1:i-1),SER,SERarray(i:length(SERarray)));
            end
        end
    end
    
    % User chooses to repeat with a different SNR, or end the program and
    % display a graph of BER vs EbNo
    prompt = 'Repeat transmission with a different SNR? Enter y or n: ';
    str = input(prompt,'s');
    if strcmpi(str,'y')
        close()
        close()
    else
        % The following calculation for theorPM, the theoretical symbol
        % error rate, is based off of Equations 8.7.15 and 8.7.16 in
        % Proakis, Salehi's Fundamentals of Communication Systems
        theorPsqrtM = 2*(1-1/sqrt(M))*qfunc(sqrt((3*10.^(EbNoarray/10)*k)/(M-1)));
        theorPM = 1-(1-theorPsqrtM).^2;
        
        %Plot results
        figure('Position', [50 10 500 700])
        subplot(3,1,1)
        plot(EbNoarray,BERarray)
        title('Observed bit error probability vs SNR')
        xlabel('Eb/No in dB')
        ylabel('#erroneous bits/#total bits')
        subplot(3,1,2)
        plot(EbNoarray,BERarray)
        title('Observed symbol error probability vs SNR')
        xlabel('Eb/No in dB')
        ylabel('#erroneous symbols/#total symbols')
        subplot(3,1,3)
        plot(EbNoarray,theorPM)
        title('Theoretical symbol error probability vs SNR')
        xlabel('Eb/No in dB')
        ylabel('Symbol error probability')
        run = false;
    end
end