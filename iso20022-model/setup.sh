#!/bin/bash


# grep "Download XSD" ISO\ 20022\ Message\ Definitions\ \|\ ISO20022.html | cut -d = -f 3 | cut -f 1 -d " " | sed -e "s/\"//g" | sed "/^$/d" > ~/Projects/iso20022/code-with-quarkus/iso20022.txt

URLS=$(cat src/main/resources/iso20022.txt)
for url in $URLS; do
  wget -c --content-disposition --directory-prefix=src/main/resources/xsd $url 
done
find src/main/resources/xsd/ -name *.zip -exec rm {} \;
rm pom.xml
cat pom.xml.start >> pom.xml
XSD=$(ls src/main/resources/xsd)
for xsdfile in $XSD; do
  xjbfile=$(echo $xsdfile | sed -e "s/xsd/xjb/")
  cp src/main/resources/template.xjb src/main/resources/xjb/$xjbfile
  sed -i -e "s/XSDSCHEMALOCATION/$xsdfile/" src/main/resources/xjb/$xjbfile
  echo "                                <xsdOption>" >> pom.xml
  echo "                                    <xsd>\${basedir}/src/main/resources/xsd/$xsdfile</xsd>" >> pom.xml
  echo "                                    <bindingFile>\${basedir}/src/main/resources/xjb/$xjbfile</bindingFile>" >> pom.xml
  echo "                                </xsdOption>" >> pom.xml
done
cat pom.xml.end >> pom.xml
