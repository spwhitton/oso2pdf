{-# LANGUAGE TemplateHaskell #-}

import           Control.Lens        hiding (argument)
import           Control.Monad       (when)
import           Data.List           (isInfixOf)
import           Options.Applicative
import           System.Directory    (findExecutable)
import           System.Exit         (die)
import           System.FilePath     (takeBaseName, (</>))
import           System.IO.Temp
import           System.Process

data Opts = Opts { _font :: String, _input :: FilePath }
makeLenses ''Opts

optsParser :: Parser Opts
optsParser = Opts
             <$> strOption    (long "font" <> metavar "FONT" <> value "Liberation Serif")
             <*> argument str (metavar "INPUT")

narrowToContent      :: String -> (String, String, String)
narrowToContent full = (body, notes ++ "</div></div>", footer)
  where
    ls               = lines full
    body = unlines
           . takeWhile (\x -> not . isInfixOf "<div id=\"notes\">" $ x)
           . dropWhile (\x -> not . isInfixOf "<div class=\"div1\">" $ x)
           $ ls
    notes = unlines
            . takeWhile (\x -> not . isInfixOf "</div></div></div>" $ x)
            . dropWhile (\x -> not . isInfixOf "<div id=\"notes\">" $ x)
            $ ls
    footer           = unlines . filter ("printFooterCopyright" `isInfixOf`) $ ls

main = do

    -- 1. check for existence of other programs we're gonna call

    pandoc         <- maybe False (const True) <$> findExecutable "pandoc"
    pandoc_oso2tex <- maybe False (const True) <$> findExecutable "pandoc-oso2tex"
    when (not pandoc) $ die "could not find pandoc executable"
    when (not pandoc_oso2tex) $ die "could not find pandoc-oso2tex executable"

    -- 2. parse command line options

    opts <- execParser $ info optsParser mempty

    -- 3. get HTML content

    (body, notes, footer) <- narrowToContent <$> readFile (opts ^. input)

    -- 4. go go go

    let contentFile = (takeBaseName $ opts ^. input) ++ "-content.pdf"
    let notesFile = (takeBaseName $ opts ^. input) ++ "-notes.pdf"
    withSystemTempDirectory "oso2pdf" $ \dir -> do
        writeFile (dir </> "content.html") (body ++ footer)
        writeFile (dir </> "notes.html") (notes ++ footer)
        runPandoc (dir </> "content.html") contentFile (opts ^. font)
        runPandoc (dir </> "notes.html") notesFile (opts ^. font)

runPandoc                   :: String -> String -> String -> IO ()
runPandoc input output font = do
    readProcess "pandoc" [ "-s"
                         , input
                         , "--filter"
                         , "pandoc-oso2tex"
                         , "--variable"
                         , "mainfont=" ++ font
                         , "--latex-engine=xelatex"
                         , "-V"
                         , "documentclass=pessay"
                         , "-V"
                         , "classoption=onehalf"
                         , "--template=pessay"
                         , "-o"
                         , output] ""
    return ()
