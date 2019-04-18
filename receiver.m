function [bitStream,receivedSymbols,finalImage] = receiver(receivedSignal,wid,len,M,useGray)
% Demodulate the received signal into a stream of bits. Reconstruct the 
% image by mapping each 8-bit group to an index in finalImage.
% bitStream - 1x(wid*len*3*8) vector containing the received bits
% receivedSymbols - 1x(wid*len*3*8/k) vector containing the integer values 
%                   of each symbol recieved
% finalImage - the reconstructed image (len x wid x 3 matrix)


% Check the value of useGray and demodulate accordingly
k = log2(M);
if useGray
    receivedSymbols = qamdemod(receivedSignal,M);
else
    receivedSymbols = qamdemod(receivedSignal,M,'bin');
end
receivedBitsMatrix = de2bi(receivedSymbols,k);
bitStream = receivedBitsMatrix(:)';   


% Traverse the bit stream by 8 bits at a time. Convert each 8-bit group
% to base 10 and map it to finalImage in the same order as the original
% image was deconstructed
finalImage = zeros(len,wid,3);
i=1;
for z=1:3
    for y=1:len
        for x=1:wid
            temp = bitStream(i:i+7); %get chunk of 8 bits, 1x8 array
            temp = num2str(temp); %convert chunk into string
            temp = temp(~isspace(temp)); %remove spaces from string
            finalImage(y,x,z) = bin2dec(temp); %put int value into final image matrix
            i = i+8; %go to next 8 bits
        end
    end
end

% Convert from double to uint8 so that the image can be properly displayed
finalImage = uint8(finalImage);

end