#!/bin/bash
cp -R sm_top.v schoolMIPS/src
if [ ! -d schoolMIPS/scripts/program/common/ ]; then
    echo "Directory is not exist. Check that git submodule is downloaded";    
    exit 1;
fi

#updating compiling files
cat << EOF > schoolMIPS/scripts/program/common/02_compile_to_hex_with_mars.sh 
#!/bin/bash
java -jar ..\..\scripts\bin\Mars4_5.jar nc a dump .text HexText program.hex main.S
if [ ! -f main1.S  ]; then
    echo "Assembly file for 2 core is not found and therefore is not compiled!. It should be called main1.S"
else
    java -jar ..\..\scripts\bin\Mars4_5.jar nc a dump .text HexText program1.hex main1.S
fi
EOF

cat << EOF > schoolMIPS/scripts/program/common/02_compile_to_hex_with_mars.bat 
java -jar ..\..\scripts\bin\Mars4_5.jar nc a dump .text HexText program.hex main.S
IF EXIST "main1.S" (
  java -jar ..\..\scripts\bin\Mars4_5.jar nc a dump .text HexText program1.hex main1.S
) ELSE (
  ECHO "Assembly file for 2 core is not found and therefore is not compiled!. It should be called main1.S"
)
EOF

#updating coping files
echo 'copy .\program1.hex ..\..\board\program' >> schoolMIPS/scripts/program/common/05_copy_program_to_board.bat 
echo 'cp .\program1.hex ..\..\board\program' >> schoolMIPS/scripts/program/common/05_copy_program_to_board.sh 