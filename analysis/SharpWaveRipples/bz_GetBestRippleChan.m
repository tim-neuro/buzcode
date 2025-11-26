function  [chan] = bz_GetBestRippleChan(lfp, hpc_channels, sampling_rate)
%Detect which hpc lfp channel has the highest SNR for the
% ripple componenent of SPWR events. returns 0 based channel idx!!
n_channels = length(lfp.channels);
mRipple = zeros(1, n_channels);
meRipple = zeros(1, n_channels);
mmRippleRatio = zeros(1, n_channels);
% filters 140-180hz - uses normalized frequencies, where 1.0 = Nyquist frequency = sampling_rate/2.
[b, a]=butter(4,[140/(sampling_rate/2) 180/(sampling_rate/2)],'bandpass');

% check on a single channel that filtering worked - if not, use lower order
% filter
filt_test = FiltFiltM(b,a,single(lfp.data(:,1)));
if sum(isnan(filt_test)) > 100
    [b, a]=butter(3,[140/(sampling_rate/2) 180/(sampling_rate/2)],'bandpass');
    disp('Lower filter order had to be used to find best ripple channel')
end
% check if it still failed
filt_test = FiltFiltM(b,a,single(lfp.data(:,1)));
if sum(isnan(filt_test)) >100 
    error('Filter failed when searching for best ripple channel')
end
for i=1:length(hpc_channels)
    chan_idx = hpc_channels(i);
    filt = FiltFiltM(b,a,single(lfp.data(:,chan_idx)));
    pow = fastrms(filt,15);    
    mRipple(chan_idx) = mean(pow);
    meRipple(chan_idx) = median(pow);
    mmRippleRatio(chan_idx) = mRipple(chan_idx)./meRipple(chan_idx);
end

mmRippleRatio(mRipple<1) = 0;
mmRippleRatio(meRipple<1) = 0;

[~, loc] = max(mmRippleRatio);
chan = lfp.channels(loc);
end