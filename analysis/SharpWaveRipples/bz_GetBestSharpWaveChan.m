function  [chan] = bz_GetBestSharpWaveChan(lfp, n_channels, sampling_rate, best_ripple_channel, coords)

% detect which lfp channel has the highest SNR for the
% Sharp wave componenent of SPWR events. Also makes sure that the channel is in
% Stratum Radiatum with respect to ripple channel (100-1000um below, on same shank)

% filters 2-50hz - uses normalized frequencies, where 1.0 = Nyquist frequency = sampling_rate/2.
[b, a]=butter(4,[2/(sampling_rate/2) 50/(sampling_rate/2)],'bandpass');

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

for i=1:n_channels
    filt = FiltFiltM(b,a,single(lfp.data(:,i)));
    pow = fastrms(filt,15);    
    mSW(i) = mean(pow);
    meSE(i) = median(pow);
    mmSWRatio(i) = mSW(i)./meSW(i);
end

mmSWRatio(mSW<1) = 0;
mmSWRatio(meSW<1) = 0;

% get x and y coord of ripple channel 
x_ripple = coords(best_ripple_channel, 1);
y_ripple = coords(best_ripple_channel, 2);

% exclude sites on other shanks (x differs more than 50um)
mmSWRatio((coords(:, 1) > x_ripple + 50) | (coords(:, 1) < x_ripple - 50)) = 0;

% exclude sites above and too close to ripple channel (min 100um below)
mmSWRatio(coords(:, 2) > y_ripple-100) = 0;

% exclude too far below ripple channel (max 1000um below)
mmSWRatio(coords(:, 2) < y_ripple-1000) = 0;

[~, loc] = max(mmSWRatio);
chan = lfp.channels(loc);
end