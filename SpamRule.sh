comp_value=$?
outlog="/var/log/spamrule.log"
spamfile="/etc/mail/spamassassin/hardtec.cf"
service=MailScanner
spamdfile="/tmp/hardtec.cf"
git="https://raw.githubusercontent.com/Crusher131/Hardtec.cf/master/hardtec.cf"


reinit.mail.func(){
if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
service mailscanner restart
else
service MailScanner restart
fi
}

comparate.func(){
    echo "Verificando arquivo baixado e arquivo atual">>$outlog
    diff --brief $spamdfile $spamfile >/dev/null
if [ $comp_value -eq 1 ]
    then
        echo "Arquivos diferentes!">>$outlog
        echo "Subistituindo arquivo atual pelo baixado">>$outlog
            cp -f $spamdfile $spamfile 2>&1 |tee -a $outlog
        echo "Reiniciando MailScanner">>$outlog
            reinit.mail.func 2>&1 |tee -a $outlog
        echo "Removendo arquivo Baixado">>$outlog
            rm $spamdfile 2>&1 |tee -a $outlog
        echo "FIM!">>$outlog
    else
        echo "Arquivo baixado e atual são iguais, Sem atualização.">>$outlog
        echo "Removendo arquivo baixado.">>$outlog
            rm $spamdfile 2>&1 |tee -a $outlog
        echo "FIM!">>$outlog
    fi
}




echo "Iniciando atualização das regras do spamassassin." > $outlog
echo "">>$outlog
echo "Efetuando download do arquivo hardtec.cf">>$outlog
echo "">>$outlog
wget --directory-prefix=/tmp/ $git --no-check-certificate 2>&1 | tee -a $outlog
echo "Download efetuado">>$outlog



echo "" >>$outlog
echo "Verificando se "$spamfile" existe" >>$outlog
if [ -f $spamfile ]; then
    echo "O arquivo existe"
    echo "">>$outlog
    comparate.func
    else
    echo "">>$outlog
    echo "Criando aruivo">>$outlog
    touch $spamfile 2>&1 |tee -a $outlog
    comparate.func
fi
