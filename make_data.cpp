// アドレスがの下位bitが00,01,10,11 のデータファイルを作る
#include <cstdio>

using namespace std;

int main(){
    FILE *org_fp, *fp0, *fp1, *fp2, *fp3;
    org_fp = fopen("/home/denjo/experiment/b3exp/benchmarks/Coremark_for_Synthesis/data.hex","r");
    if (org_fp == NULL){
        printf("Cannot open file\n");
        return 0;
    }

    fp0 = fopen("data0.hex","w");
    fp1 = fopen("data1.hex","w");
    fp2 = fopen("data2.hex","w");
    fp3 = fopen("data3.hex","w");

    int i = 0;
    char buf[8];
    char buf0[3], buf1[3], buf2[3], buf3[3];
    while (fscanf(org_fp,"%s",buf)!= EOF){
        for (int j = 0; j < 2; j++){
            buf0[j] = buf[j+6];
            buf1[j] = buf[j+4];
            buf2[j] = buf[j+2];
            buf3[j] = buf[j];
        }
        buf0[2] = '\n';
        buf1[2] = '\n';
        buf2[2] = '\n';
        buf3[2] = '\n';
        fwrite(buf0,1,3,fp0);
        fwrite(buf1,1,3,fp1);
        fwrite(buf2,1,3,fp2);
        fwrite(buf3,1,3,fp3);
    }
    return 0;
}