%2020.11.18
%产生扫频干扰数据作为分类数据,干扰JNR=30-60dB，扫频周期40-80us，扫频带宽20Mhz
close all;clear;clc
j=sqrt(-1);
data_num=500;   %干扰样本数
samp_num=2000;%距离窗点数
fs = 20e6; %采样频率
B = 10e6;  %信号带宽
taup = 20e-6; %信号脉宽
t = linspace(taup/2,taup/2*3,taup*fs);          %时间序列
lfm = exp(1j*pi*B/taup*t.^2);          %LFM信号

SNR=0; %信噪比dB
echo=zeros(data_num,samp_num,3);     %矩阵大小（500,2000,2）
echo_stft=zeros(data_num,100,247,3);  %矩阵大小（500,200,1000,2）
num_label = 7;
label=zeros(1,data_num)+num_label;                         %标签数据,此干扰标签为0

for m=1:data_num
    JNR=30+round(rand(1,1)*30); %干噪比30-60dB
    T=40*1e-6+round((rand(1,1)*40))*1e-6;%扫频周期20-40us
    t1 = linspace(0,T,T*fs);          %时间序列
    B1=2*B;

    swept = exp(1j*pi*B1/T*t1.^2);          %swept信号
    jam=swept;
    spp=randn([1,length(jam)])+1j*randn([1,length(jam)]);
    sppfft=fft(spp);
    sppfft(1:length(sppfft)/2-80)=0;sppfft(length(sppfft)/2+80:length(sppfft))=0;
    spp=ifft(sppfft);
     jam=swept.*spp;
    x=(1+square(0.25*pi*10^6*t1,60))/2;
%      jam=jam.*x;
    
    sp=randn([1,samp_num])+1j*randn([1,samp_num]);%噪声基底
    sp1=sp;
    sp=sp/std(sp);
    As=10^(SNR/20);%目标回波幅度
    Aj=10^(JNR/20);%干扰回波幅度
    range_tar=1+round(rand(1,1)*1400);
    
    sp(1+range_tar:length(lfm)+range_tar)=sp(1+range_tar:length(lfm)+range_tar)+As*lfm;  %噪声+目标回波 目标在距离窗内200点处
    if length(jam)<1001
        sp(1:length(jam))=sp(1:length(jam))+Aj*jam;
        sp(length(jam)+1:2*length(jam))=sp(length(jam)+1:2*length(jam))+Aj*jam;
    else
        sp(1:length(jam))=sp(1:length(jam))+Aj*jam;
    end
    

    sp=sp/max(max(sp));
    sp_abs=abs(sp);
     figure(3)
    plot(linspace(0,100,2000),sp);xlabel('时间/μs','FontSize',20);ylabel('归一化幅度','FontSize',20)
    
    echo(m,1:2000,1)=real(sp); 
    echo(m,1:2000,2)=imag(sp);
    echo(m,1:2000,3)=sp_abs; 
%     echo(m,1:2000,4)=angle(sp); %信号实部、虚部分开存入三维张量中
   [S,~,~,~]=spectrogram(sp,32,32-8,100,20e6);
 
   
   
    S=S/max(max(S));
    S_abs=abs(S);
    figure(4)
    imagesc(linspace(0,100,size(S,1)),linspace(-10,10,size(S,2)),abs(S));
    xlabel('时间/μs','FontSize',20);ylabel('频率/MHz','FontSize',20)
    
    echo_stft(m,1:size(S,1),1:size(S,2),1)=real(S);
    echo_stft(m,1:size(S,1),1:size(S,2),2)=imag(S);
    echo_stft(m,1:size(S,1),1:size(S,2),3)=S_abs;
%     echo_stft(m,1:size(S,1),1:size(S,2),4)=angle(S);
    
end
% 
% % save('F:\deep_learning_for_active_jamming_2020.11.16\jamming_data\swept_jam_7\echo.mat' ,'echo')
% % save('F:\deep_learning_for_active_jamming_2020.11.16\jamming_data\swept_jam_7\echo_stft.mat' ,'echo_stft')
% % save('F:\deep_learning_for_active_jamming_2020.11.16\jamming_data\swept_jam_7\label.mat' ,'label')

t_data=load('D:\CodeSpace\active_jamming_recognition\data\t_data.mat').t_data;
tf_data=load('D:\CodeSpace\active_jamming_recognition\data\tf_data.mat').tf_data;
gt_label=load('D:\CodeSpace\active_jamming_recognition\data\gt_label.mat').gt_label;
% 
t_data(1+500*(num_label):500*(num_label+1),:,:)=echo; 
tf_data(1+500*(num_label):500*(num_label+1),:,:,:)=echo_stft; 
gt_label(1,1+500*(num_label):500*(num_label+1))=label;
% 
save('D:\CodeSpace\active_jamming_recognition\data\t_data.mat','t_data')
save('D:\CodeSpace\active_jamming_recognition\data\tf_data.mat','tf_data')
save('D:\CodeSpace\active_jamming_recognition\data\gt_label.mat','gt_label')


