function out = getFFT(y,fftpnts,n)

    Y = fft(y(n:n+fftpnts));
	% compute the two-sided spectrum P2.
    P2 = abs(Y/fftpnts);
    % compute the single-sided spectrum P1 based on P2 and the even-valued
    % signal length fftpnts
    P1 = P2(1:fftpnts/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    out = P1;
    
end