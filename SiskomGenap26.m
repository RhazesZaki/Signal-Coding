clear all
jdata=20;T=1;jsampel=100;fc=1/T;E=1;
b=randi([0 1],1,jdata);
sp=reshape(b,2,[]);
mapping=2*sp-1;
mapI=sqrt(E/2)*mapping(1,:);
mapQ=sqrt(E/2)*mapping(2,:);
t=0:T/jsampel:T-(T/jsampel);
b1=sqrt(2/T)*cos(2*pi*fc*t);
b2=-sqrt(2/T)*sin(2*pi*fc*t);
figure (1)
subplot(2,1,1)
plot(t,b1)
subplot(2,1,2)
plot(t,b2)
sI=b1'*mapI;
sQ=b2'*mapQ;
QPSK=sI+sQ;
QPSKs=reshape(QPSK,1,[]);
tt=0:length(QPSKs)-1; tt=tt/jsampel;
figure (2)
plot(tt,QPSKs)
SpektrumQPSK=fft(QPSK,1024);
f=0:length(SpektrumQPSK)-1;
f=(T/jsampel)*f/length(SpektrumQPSK);
figure (3)
plot(f,abs(SpektrumQPSK))
figure (4)
plot(mapI,mapQ,'*r')
axis([-2 2 -2 2])
%======penerima
Eb_NodB=0:10;
Eb_No=10.^(Eb_NodB/10);
for k=1:length(Eb_No);
rt=awgn(QPSKs,Eb_NodB(1,k),10*log10(jsampel)-6);
figure(5)
plot(tt,rt)
rx=reshape(rt,jsampel,[]);
z1=b1*rx*(T/jsampel);
z2=b2*rx*(T/jsampel);
figure(6)
plot(mapI,mapQ,'*r',z1,z2,'.b')
dI=sign(z1);
dQ=sign(z2);
bEst=([dI;dQ]+1)/2;
bEs=reshape(bEst,1,[]);
[N(k),BER(k)]=biterr(b,bEs);
end
BERteori=qfunc(sqrt(2*Eb_No));
figure (1)
semilogy(Eb_NodB,BER,'o-r',Eb_NodB,BERteori,'b')
legend('BER simulasi','BER Teori')
