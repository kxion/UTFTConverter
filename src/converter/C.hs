module C (toCFile) where

import Data.Time (UTCTime)
import RGB565    (to4Hex)

toCFile :: [String] -> String -> (Int, Int) -> UTCTime -> String
toCFile content name (w, h) time = let clength  = show (length content)
                                       memusage = show (length content * 2) in
  "// Generated by   : JuicyConverter v0.1\n"                          ++
  "// Generated from : " ++ name      ++ ".jpg\n"                      ++
  "// Time generated : " ++ show time ++ "\n"                          ++
  "// Image Size     : " ++ show w ++ 'x' : show h ++ " pixels\n"      ++
  "// Memory usage   : " ++ memusage  ++ " bytes\n"                    ++
  "\n\n"                                                               ++
  "#if defined(__AVR__)\n"                                             ++
  "    #include <avr/pgmspace.h>\n"                                    ++
  "#elif defined(__PIC32MX__)\n"                                       ++
  "    #define PROGMEM\n"                                              ++
  "#elif defined(__arm__)\n"                                           ++
  "    #define PROGMEM\n"                                              ++
  "#endif\n"                                                           ++
  "\n"                                                                 ++
  "const unsigned short " ++ name ++ '[' : clength ++ "] PROGMEM={\n"  ++
  toCArray content 1

toCArray :: [String] -> Int -> String
toCArray []     _ = "};"
toCArray (x:xs) n = printHex x ++ com ++ toCArray xs (n+1)
  where com | n `mod` 16 == 0 = printCom n
            | otherwise       = ""

printHex :: String -> String
printHex hx = '0':'x': hx ++ ", "

printCom :: Int -> String
printCom n = ' ':' ':'/':'/':' ':'0':'x': to4Hex n ++ ' ':'(': show n ++ ") pixels\n"