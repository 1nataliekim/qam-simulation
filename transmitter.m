function [bitStream,symbols,sentSignal] = transmitter(I,wid,len,M,useGray)
% Convert each integer in I (len x wid x 3 matrix) into its binary 
% representation using 8 bits. Concatenate all bits into a single stream
% called bitStream. Split the bit stream into k-tuples and modulate.
% bitStream - 1x(wid*len*3*8) vector containing the binary representation
%             of the image before modulation
% symbols - 1x(wid*len*3*8/k) vector containing the integer values of each
%           symbol to be sent
% sentSignal - the modulated signal


% Create the bit stream
bitStream = "";
for z=1:3
    for y=1:len
        for x=1:wid
            bin = dec2bin(I(y,x,z),8);
            temp = bin(1)+" "+bin(2)+" "+bin(3)+" "+bin(4)+" "+bin(5)+" "+bin(6)+" "+bin(7)+" "+bin(8)+" ";
            bitStream = bitStream + temp;
        end
    end
end
bitStream = str2num(bitStream);


% Check the value of useGray and modulate accordingly
k=log2(M);
bitsMatrix = reshape(bitStream',length(bitStream')/k,k);
symbols = bi2de(bitsMatrix);
if useGray
    sentSignal = qammod(symbols,M); 
else
    sentSignal = qammod(symbols,M,'bin');
end


end