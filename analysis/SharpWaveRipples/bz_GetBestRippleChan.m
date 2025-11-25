function  [chan] = bz_GetBestRippleChan(lfp, n_channels, sampling_rate)
%[chan] = bz_GetBestRippleChan(lfp)
%eventually this will detect which lfp channel has the highest SNR for the
% ripple componenent of SPWR events....

% filters 140-180hz - uses normalized frequencies, where 1.0 = Nyquist frequency = sampling_rate/2.
[b a]=butter(4,[140/(sampling_rate/2) 180/(sampling_rate/2)],'bandpass');

for i=1:n_channels
    filt = FiltFiltM(b,a,single(lfp(:,i)));
    pow = fastrms(filt,15);    
    mRipple(i) = mean(pow);
    meRipple(i) = median(pow);
    mmRippleRatio(i) = mRipple(i)./meRipple(i);
end

mmRippleRatio(mRipple<1) = 0;
mmRippleRatio(meRipple<1) = 0;

[minVal loc] = max(mmRippleRatio);
chan = lfp.channels(loc);
end