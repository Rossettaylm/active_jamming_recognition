%2020.11.16
%产生密集假目标干扰（延时叠加型）作为分类数据，干噪比30-60dB之间随机；假目标个数3-6个；假目标间延迟时间1-10us；
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
num_label = 1;
label=zeros(1,data_num)+num_label;                         %标签数据,此干扰标签为0
for m=1:data_num
    JNR=30+round(rand(1,1)*30); %干噪比30-60dB
    sp=randn([1,samp_num])+1j*randn([1,samp_num]);%噪声基底
    sp=sp/std(sp);

    As=10^(SNR/20);%目标回波幅度
    Aj=10^(JNR/20);%干扰回波幅度
    range_tar=1+round(rand(1,1)*100);
    sp(1+range_tar:length(lfm)+range_tar)=sp(1+range_tar:length(lfm)+range_tar)+As*lfm;  %噪声+目标回波 目标在距离窗内range_tar点处

    k=3+round(rand(1,1)*3);%改为随机产生3-6（个假目标）
    delay_time=(1+round(rand(1,1)*9))*1e-6;%改为随机延迟1-10us
    delay_num=delay_time*fs;

    for i=0:k-1 %距离窗内添加多个假目标干扰
        sp(range_tar+401+i*delay_num:range_tar+800+i*delay_num)=sp(range_tar+401+i*delay_num:range_tar+800+i*delay_num)+Aj*lfm;
      
    end
    

    sp=sp/max(max(sp));
    sp_abs=abs(sp);
    
    figure(3)
    plot(linspace(0,100,2000),sp);
    set(gca,'FontName','Times New Roman');
    xlabel('Time/μs','FontSize',15);ylabel('Normalized amplitude','FontSize',15)
     
    
    echo(m,1:2000,1)=real(sp); 
    echo(m,1:2000,2)=imag(sp);
    echo(m,1:2000,3)=sp_abs; 
%     echo(m,1:2000,4)=angle(sp);%信号实部、虚部分开存入三维张量中
    [S,~,~,~]=spectrogram(sp,32,32-8,100,20e6);
    
    S=S/max(max(S));
    S_abs=abs(S);
    figure(4)
    imagesc(linspace(0,100,size(S,1)),linspace(-10,10,size(S,2)),abs(S));
    set(gca,'FontName','Times New Roman');
    xlabel('Time/μs','FontSize',15);ylabel('Frequency/MHz','FontSize',15)
    
    echo_stft(m,1:size(S,1),1:size(S,2),1)=real(S);
    echo_stft(m,1:size(S,1),1:size(S,2),2)=imag(S);
    echo_stft(m,1:size(S,1),1:size(S,2),3)=S_abs;
%     echo_stft(m,1:size(S,1),1:size(S,2),4)=angle(S);
    
end
% save('F:\deep_learning_for_active_jamming_2020.11.16\jamming_data\Dense_false_target_jam_1\echo.mat' ,'echo')
% save('F:\deep_learning_for_active_jamming_2020.11.16\jamming_data\Dense_false_target_jam_1\echo_stft.mat' ,'echo_stft')
% save('F:\deep_learning_for_active_jamming_2020.11.16\jamming_data\Dense_false_target_jam_1\label.mat' ,'label')


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



