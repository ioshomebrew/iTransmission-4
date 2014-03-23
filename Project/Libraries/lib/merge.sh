export DIR1="/Users/dhruvitraithatha/GitHub/iTransmission-4/Project/Libraries/lib/"
export DIR2=" /Users/dhruvitraithatha/GitHub/iTransmission-4-master/Compilation/out.d/x86_64/lib/"

lipo -create ${DIR1}lib$1.a ${DIR2}lib$1.a -o ./lib$1.a

rm ${DIR1}lib$1.a ${DIR2}lib$1.a