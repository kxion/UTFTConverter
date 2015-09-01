
-----------------------------------------------------------------------------
-- |
-- Module      :  Format.C
-- License     :  MIT
-- Maintainer  :  Alexander Isenko <alex.isenko@googlemail.com>
-----------------------------------------------------------------------------

module Format.C (toCFile, Platform(..)) where

import Data.Time        (UTCTime)
import Format.RGB565    (to4Hex)


-- | The Platform datatype has three constructors, for every supported architecture
--
-- The Show instance is derived
data Platform = AVR
              | ARM
              | PIC32
  deriving Show

-- | toCFile gets five arguments
--
-- * @[String]@ are the hex strings
-- * @(String, String)@ is the (filename, file extention)
-- * @(Int, Int) is the (width, height)
-- * UTCTime is the current time
-- * Platform is the desired platform to convert to
--
-- The result is a the string which is the full c file with header + unsigned short array + comments
--
-- The created @\\n@ were reformatted by hand
--
-- __Example usage:__
--
-- @
-- λ> let hex = ["0000", "0000", \"FF00\", "00FF","0000", "0000", \"FF00\", "00FF", "0000", "0000", \"FF00\", "00FF", "0000", "0000", \"FF00\", "00FF"]
-- λ> time <- getCurrentTime
-- λ> toCFile hex ("example", ".jpg") (4,4) time AVR
-- "\/\/ Generated by   : UTFTConverter v0.1
--  \/\/ Generated from : example.jpg
--  \/\/ Time generated : 2015-09-01 19:56:40.438958 UTC
--  \/\/ Image Size     : 4x4 pixels
--  \/\/ Memory usage   : 32 bytes
--
--
-- #include \<avr/pgmspace.h\>
-- const unsigned short example[16] PROGMEM={
-- 0x0000, 0x0000, 0xFF00, 0x00FF, 0x0000, 0x0000, 0xFF00, 0x00FF, 0x0000, 0x0000, 0xFF00, 0x00FF, 0x0000, 0x0000, 0xFF00, 0x00FF,   \/\/ 0x0010 (16) pixels
-- };"
-- @

toCFile :: [String] -> (String, String) -> (Int, Int) -> UTCTime -> Platform -> String
toCFile content (name, ext) (w, h) time platform =
  let clength  = show (length content)
      memusage = show (length content * 2)
      include  | AVR <- platform = "\n#include <avr/pgmspace.h>\n"
               | otherwise       = ""
      arrname  | AVR <- platform = "const unsigned short " ++ name ++ '[' : clength ++ "] PROGMEM={\n"
               | otherwise       = "const unsigned short " ++ name ++ '[' : clength ++ "] ={\n"
  in
  "// Generated by   : UTFTConverter v0.1\n"                           ++
  "// Generated from : " ++ name      ++ ext ++ "\n"                   ++
  "// Time generated : " ++ show time ++ "\n"                          ++
  "// Image Size     : " ++ show w ++ 'x' : show h ++ " pixels\n"      ++
  "// Memory usage   : " ++ memusage  ++ " bytes\n"                    ++
  include                                                              ++
  "\n"                                                                 ++
  arrname                                                              ++
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
