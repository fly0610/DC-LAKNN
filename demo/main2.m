clear
%sonar¡ª208 (60)
s4=load('D:\knn_lyf\data\UCI\sonar');
load('D:\knn_lyf\data\Data_cv\sonar\data_cv');
load('D:\knn_lyf\data\Data_cv\sonar\label_cv');
class=2;
[e4,k4]=pro_improve2(s4,data_cv,label_cv,class,10,20);
