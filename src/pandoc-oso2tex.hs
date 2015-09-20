{-

    oso2pdf --- Better conversion of Oxford Scholarship Online material to PDF

    Copyright (C) 2015  Sean Whitton

    This file is part of oso2pdf.

    oso2pdf is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    oso2pdf is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with oso2pdf.  If not, see <http://www.gnu.org/licenses/>.

-}

import           Data.List        (isPrefixOf, isSuffixOf)
import           Data.Monoid      ((<>))
import           Text.Pandoc.JSON

data Page = Page Int [Block]

instance Monoid Page where
    mempty                            = Page 1 []
    (Page n xs) `mappend` (Page _ ys) = Page n (xs ++ ys)

pagesToBlocks :: [Page] -> [Block]
pagesToBlocks [Page _ xs] = xs
pagesToBlocks ps@( _ : (Page n _) : _) =
    RawBlock (Format "tex") ("\\setcounter{page}{" ++ show (n - 1) ++ "}")
    : (drop 1 $ foldr step [] ps) -- drop first \\pagebreak
  where
    step (Page n p) ps = RawBlock (Format "tex") "\\pagebreak" : p ++ ps

-- TODO factor out joining Pages together and appending or just
-- putting side by side

blocksToPages :: [Block] -> [Page]
blocksToPages = foldr step []
  where
    step (Para xs) [] = paraToPages xs
    step x [] = [Page 1 [x]]
    step (Para xs) ( y@(Page n _) : ys ) =
        case paraToPages xs of
            [a, b] -> if n /= 1 then a : b : y : ys else a : (b <> y) : ys
            [a]    -> if n /= 1 then a : y : ys else (a <> y) : ys
    step x (y:ys) = ((Page 1 [x]) <> y) : ys

-- ASSUME: not more than one page break per paragraph!
paraToPages      :: [Inline] -> [Page]
paraToPages para = let (first, n, second) = foldr step ([], 1, []) para
                   in if n == 1
                      then [Page 1 [Para second]]
                      else if null first
                           then [Page 1 [Para first], Page n [Para second]]
                           else [ Page 1 [Para first]
                                , Page n [Para (RawInline (Format "tex") "\\noindent"
                                                : second)]]
  where
    step chunk (xs, n, ys) =
        if n /= 1
        then (chunk : xs, n, ys)
        else case chunk of
            (Str x) -> if "(p." `isPrefixOf` x && ")" `isSuffixOf` x
                       then let m = read . drop 3 . init $ x
                            in (xs, m, ys) -- TODO: what about [Space, Space] left behind?
                       else (xs, n, chunk : ys)
            _       -> (xs, n, chunk : ys)

main = toJSONFilter process
  where
    process (Pandoc meta blocks) = Pandoc meta (pagesToBlocks . blocksToPages $ blocks)
