# SPDX-FileCopyrightText: 2019 Omar Roth <omarroth@protonmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require "kemal"
require "openssl/hmac"
require "pg"
require "spec"
require "yaml"
require "../src/invidious/helpers/*"
require "../src/invidious/channels"
require "../src/invidious/comments"
require "../src/invidious/playlists"
require "../src/invidious/search"
require "../src/invidious/users"

describe "Helper" do
  describe "#produce_channel_videos_url" do
    it "correctly produces url for requesting page `x` of a channel's videos" do
      produce_channel_videos_url(ucid: "UCXuqSBlHAE6Xw-yeJA0Tunw").should eq("/browse_ajax?continuation=4qmFsgI8EhhVQ1h1cVNCbEhBRTZYdy15ZUpBMFR1bncaIEVnWjJhV1JsYjNNd0FqZ0JZQUZxQUxnQkFDQUFlZ0V4&gl=US&hl=en")

      produce_channel_videos_url(ucid: "UCXuqSBlHAE6Xw-yeJA0Tunw", sort_by: "popular").should eq("/browse_ajax?continuation=4qmFsgJCEhhVQ1h1cVNCbEhBRTZYdy15ZUpBMFR1bncaJkVnWjJhV1JsYjNNd0FqZ0JZQUZxQUxnQkFDQUFlZ0V4R0FFJTNE&gl=US&hl=en")

      produce_channel_videos_url(ucid: "UCXuqSBlHAE6Xw-yeJA0Tunw", page: 20).should eq("/browse_ajax?continuation=4qmFsgJEEhhVQ1h1cVNCbEhBRTZYdy15ZUpBMFR1bncaKEVnWjJhV1JsYjNNd0FqZ0JZQUZxQUxnQkFDQUFlZ0l5TUElM0QlM0Q%3D&gl=US&hl=en")

      produce_channel_videos_url(ucid: "UC-9-kyTW8ZkZNDHQJ6FgpwQ", page: 20, sort_by: "popular").should eq("/browse_ajax?continuation=4qmFsgJAEhhVQy05LWt5VFc4WmtaTkRIUUo2Rmdwd1EaJEVnWjJhV1JsYjNNd0FqZ0JZQUZxQUxnQkFDQUFlZ0l5TUJnQg%3D%3D&gl=US&hl=en")
    end
  end

  describe "#produce_channel_search_url" do
    it "correctly produces token for searching a specific channel" do
      produce_channel_search_url("UCXuqSBlHAE6Xw-yeJA0Tunw", "", 100).should eq("/browse_ajax?continuation=4qmFsgI-EhhVQ1h1cVNCbEhBRTZYdy15ZUpBMFR1bncaIEVnWnpaV0Z5WTJnd0FqZ0JZQUZxQUxnQkFIb0RNVEF3WgA%3D&gl=US&hl=en")

      produce_channel_search_url("UCXuqSBlHAE6Xw-yeJA0Tunw", "По ожиशुपतिरपि子而時ஸ்றீனி", 0).should eq("/browse_ajax?continuation=4qmFsgKAARIYVUNYdXFTQmxIQUU2WHcteWVKQTBUdW53GiRFZ1p6WldGeVkyZ3dBamdCWUFGcUFMZ0JBSG9CTUElM0QlM0RaPtCf0L4g0L7QttC44KS24KWB4KSq4KSk4KS_4KSw4KSq4KS_5a2Q6ICM5pmC4K644K-N4K6x4K-A4K6p4K6_&gl=US&hl=en")
    end
  end

  describe "#produce_channel_playlists_url" do
    it "correctly produces a /browse_ajax URL with the given UCID and cursor" do
      produce_channel_playlists_url("UCCj956IF62FbT7Gouszaj9w", "AIOkY9EQpi_gyn1_QrFuZ1reN81_MMmI1YmlBblw8j7JHItEFG5h7qcJTNd4W9x5Quk_CVZ028gW").should eq("/browse_ajax?continuation=4qmFsgLRARIYVUNDajk1NklGNjJGYlQ3R291c3phajl3GrQBRWdsd2JHRjViR2x6ZEhNWUF5QUJNQUk0QVdBQmFnQjZabEZWYkZCaE1XczFVbFpHZDJGV09XNWxWelI0V0RGR2VWSnVWbUZOV0Vwc1ZHcG5lRmd3TVU1aVZXdDRWMWN4YzFGdFNuTmtlbWh4VGpCd1NWTllVa1pTYTJNeFlVUmtlRmt3Y0ZWVWJWRXdWbnBzTkU1V1JqRmhNVGxFVm14dmQwMXFhRzVXZDdnQkFBJTNEJTNE&gl=US&hl=en")
    end
  end

  describe "#extract_channel_playlists_cursor" do
    it "correctly extracts a playlists cursor from the given URL" do
      extract_channel_playlists_cursor("/browse_ajax?continuation=4qmFsgLRARIYVUNDajk1NklGNjJGYlQ3R291c3phajl3GrQBRWdsd2JHRjViR2x6ZEhNWUF5QUJNQUk0QVdBQmFnQjZabEZWYkZCaE1XczFVbFpHZDJGV09XNWxWelI0V0RGR2VWSnVWbUZOV0Vwc1ZHcG5lRmd3TVU1aVZXdDRWMWN4YzFGdFNuTmtlbWh4VGpCd1NWTllVa1pTYTJNeFlVUmtlRmt3Y0ZWVWJWRXdWbnBzTkU1V1JqRmhNVGxFVm14dmQwMXFhRzVXZDdnQkFBJTNEJTNE&gl=US&hl=en", false).should eq("AIOkY9EQpi_gyn1_QrFuZ1reN81_MMmI1YmlBblw8j7JHItEFG5h7qcJTNd4W9x5Quk_CVZ028gW")
    end
  end

  describe "#produce_playlist_url" do
    it "correctly produces url for requesting index `x` of a playlist" do
      produce_playlist_url("UUCla9fZca4I7KagBtgRGnOw", 0).should eq("/browse_ajax?continuation=4qmFsgIsEhpWTFVVQ2xhOWZaY2E0STdLYWdCdGdSR25PdxoOZWdaUVZEcERRVUUlM0Q%3D&gl=US&hl=en")

      produce_playlist_url("UCCla9fZca4I7KagBtgRGnOw", 0).should eq("/browse_ajax?continuation=4qmFsgIsEhpWTFVVQ2xhOWZaY2E0STdLYWdCdGdSR25PdxoOZWdaUVZEcERRVUUlM0Q%3D&gl=US&hl=en")

      produce_playlist_url("PLt5AfwLFPxWLNVixpe1w3fi6lE2OTq0ET", 0).should eq("/browse_ajax?continuation=4qmFsgI2EiRWTFBMdDVBZndMRlB4V0xOVml4cGUxdzNmaTZsRTJPVHEwRVQaDmVnWlFWRHBEUVVFJTNE&gl=US&hl=en")

      produce_playlist_url("PLt5AfwLFPxWLNVixpe1w3fi6lE2OTq0ET", 10000).should eq("/browse_ajax?continuation=4qmFsgI0EiRWTFBMdDVBZndMRlB4V0xOVml4cGUxdzNmaTZsRTJPVHEwRVQaDGVnZFFWRHBEU2tKUA%3D%3D&gl=US&hl=en")

      produce_playlist_url("PL55713C70BA91BD6E", 0).should eq("/browse_ajax?continuation=4qmFsgImEhRWTFBMNTU3MTNDNzBCQTkxQkQ2RRoOZWdaUVZEcERRVUUlM0Q%3D&gl=US&hl=en")

      produce_playlist_url("PL55713C70BA91BD6E", 10000).should eq("/browse_ajax?continuation=4qmFsgIkEhRWTFBMNTU3MTNDNzBCQTkxQkQ2RRoMZWdkUVZEcERTa0pQ&gl=US&hl=en")
    end
  end

  describe "#produce_search_params" do
    it "correctly produces token for searching with specified filters" do
      produce_search_params.should eq("CAASAhAB")

      produce_search_params(sort: "upload_date", content_type: "video").should eq("CAISAhAB")

      produce_search_params(content_type: "playlist").should eq("CAASAhAD")

      produce_search_params(sort: "date", content_type: "video", features: ["hd", "cc", "purchased", "hdr"]).should eq("CAISCxABIAEwAUgByAEB")

      produce_search_params(content_type: "channel").should eq("CAASAhAC")
    end
  end

  describe "#produce_comment_continuation" do
    it "correctly produces a continuation token for comments" do
      produce_comment_continuation("_cE8xSu6swE", "ADSJ_i2qvJeFtL0htmS5_K5Ctj3eGFVBMWL9Wd42o3kmUL6_mAzdLp85-liQZL0mYr_16BhaggUqX652Sv9JqV6VXinShSP-ZT6rL4NolPBaPXVtJsO5_rA_qE3GubAuLFw9uzIIXU2-HnpXbdgPLWTFavfX206hqWmmpHwUOrmxQV_OX6tYkM3ux3rPAKCDrT8eWL7MU3bLiNcnbgkW8o0h8KYLL_8BPa8LcHbTv8pAoNkjerlX1x7K4pqxaXPoyz89qNlnh6rRx6AXgAzzoHH1dmcyQ8CIBeOHg-m4i8ZxdX4dP88XWrIFg-jJGhpGP8JUMDgZgavxVx225hUEYZMyrLGler5em4FgbG62YWC51moLDLeYEA").should eq("EiYSC19jRTh4U3U2c3dFwAEByAEB4AEBogINKP___________wFAABgGMowDCvYCQURTSl9pMnF2SmVGdEwwaHRtUzVfSzVDdGozZUdGVkJNV0w5V2Q0Mm8za21VTDZfbUF6ZExwODUtbGlRWkwwbVlyXzE2QmhhZ2dVcVg2NTJTdjlKcVY2VlhpblNoU1AtWlQ2ckw0Tm9sUEJhUFhWdEpzTzVfckFfcUUzR3ViQXVMRnc5dXpJSVhVMi1IbnBYYmRnUExXVEZhdmZYMjA2aHFXbW1wSHdVT3JteFFWX09YNnRZa00zdXgzclBBS0NEclQ4ZVdMN01VM2JMaU5jbmJna1c4bzBoOEtZTExfOEJQYThMY0hiVHY4cEFvTmtqZXJsWDF4N0s0cHF4YVhQb3l6ODlxTmxuaDZyUng2QVhnQXp6b0hIMWRtY3lROENJQmVPSGctbTRpOFp4ZFg0ZFA4OFhXcklGZy1qSkdocEdQOEpVTURnWmdhdnhWeDIyNWhVRVlaTXlyTEdsZXI1ZW00RmdiRzYyWVdDNTFtb0xETGVZRUEiDyILX2NFOHhTdTZzd0UwACgU")

      produce_comment_continuation("_cE8xSu6swE", "ADSJ_i1yz21HI4xrtsYXVC-2_kfZ6kx1yjYQumXAAxqH3CAd7ZxKxfLdZS1__fqhCtOASRbbpSBGH_tH1J96Dxux-Qfjk-lUbupMqv08Q3aHzGu7p70VoUMHhI2-GoJpnbpmcOxkGzeIuenRS_ym2Y8fkDowhqLPFgsS0n4djnZ2UmC17F3Ch3N1S1UYf1ZVOc991qOC1iW9kJDzyvRQTWCPsJUPneSaAKW-Rr97pdesOkR4i8cNvHZRnQKe2HEfsvlJOb2C3lF1dJBfJeNfnQYeh5hv6_fZN7bt3-JL1Xk3Qc9NXNxmmbDpwAC_yFR8dthFfUJdyIO9Nu1D79MLYeR-H5HxqUJokkJiGIz4lTE_CXXbhAI").should eq("EiYSC19jRTh4U3U2c3dFwAEByAEB4AEBogINKP___________wFAABgGMokDCvMCQURTSl9pMXl6MjFISTR4cnRzWVhWQy0yX2tmWjZreDF5allRdW1YQUF4cUgzQ0FkN1p4S3hmTGRaUzFfX2ZxaEN0T0FTUmJicFNCR0hfdEgxSjk2RHh1eC1RZmprLWxVYnVwTXF2MDhRM2FIekd1N3A3MFZvVU1IaEkyLUdvSnBuYnBtY094a0d6ZUl1ZW5SU195bTJZOGZrRG93aHFMUEZnc1MwbjRkam5aMlVtQzE3RjNDaDNOMVMxVVlmMVpWT2M5OTFxT0MxaVc5a0pEenl2UlFUV0NQc0pVUG5lU2FBS1ctUnI5N3BkZXNPa1I0aThjTnZIWlJuUUtlMkhFZnN2bEpPYjJDM2xGMWRKQmZKZU5mblFZZWg1aHY2X2ZaTjdidDMtSkwxWGszUWM5TlhOeG1tYkRwd0FDX3lGUjhkdGhGZlVKZHlJTzlOdTFENzlNTFllUi1INUh4cVVKb2trSmlHSXo0bFRFX0NYWGJoQUkiDyILX2NFOHhTdTZzd0UwACgU")

      produce_comment_continuation("29-q7YnyUmY", "").should eq("EiYSCzI5LXE3WW55VW1ZwAEByAEB4AEBogINKP___________wFAABgGMhMiDyILMjktcTdZbnlVbVkwAHgC")

      produce_comment_continuation("CvFH_6DNRCY", "").should eq("EiYSC0N2RkhfNkROUkNZwAEByAEB4AEBogINKP___________wFAABgGMhMiDyILQ3ZGSF82RE5SQ1kwAHgC")
    end
  end

  describe "#produce_comment_reply_continuation" do
    it "correctly produces a continuation token for replies to a given comment" do
      produce_comment_reply_continuation("cIHQWOoJeag", "UCq6VFHwMzcMXbuKyG7SQYIg", "Ugx1IP_wGVv3WtGWcdV4AaABAg").should eq("EiYSC2NJSFFXT29KZWFnwAEByAEB4AEBogINKP___________wFAABgGMk0aSxIaVWd4MUlQX3dHVnYzV3RHV2NkVjRBYUFCQWciAggAKhhVQ3E2VkZId016Y01YYnVLeUc3U1FZSWcyC2NJSFFXT29KZWFnQAFICg%3D%3D")

      produce_comment_reply_continuation("cIHQWOoJeag", "UCq6VFHwMzcMXbuKyG7SQYIg", "Ugza62y_TlmTu9o2RfF4AaABAg").should eq("EiYSC2NJSFFXT29KZWFnwAEByAEB4AEBogINKP___________wFAABgGMk0aSxIaVWd6YTYyeV9UbG1UdTlvMlJmRjRBYUFCQWciAggAKhhVQ3E2VkZId016Y01YYnVLeUc3U1FZSWcyC2NJSFFXT29KZWFnQAFICg%3D%3D")

      produce_comment_reply_continuation("_cE8xSu6swE", "UC1AZY74-dGVPe6bfxFwwEMg", "UgyBUaRGHB9Jmt1dsUZ4AaABAg").should eq("EiYSC19jRTh4U3U2c3dFwAEByAEB4AEBogINKP___________wFAABgGMk0aSxIaVWd5QlVhUkdIQjlKbXQxZHNVWjRBYUFCQWciAggAKhhVQzFBWlk3NC1kR1ZQZTZiZnhGd3dFTWcyC19jRTh4U3U2c3dFQAFICg%3D%3D")
    end
  end

  describe "#produce_channel_community_continuation" do
    it "correctly produces a continuation token for a channel community" do
      produce_channel_community_continuation("UCCj956IF62FbT7Gouszaj9w", "Egljb21tdW5pdHm4").should eq("4qmFsgIsEhhVQ0NqOTU2SUY2MkZiVDdHb3VzemFqOXcaEEVnbGpiMjF0ZFc1cGRIbTQ%3D")
      produce_channel_community_continuation("UCCj956IF62FbT7Gouszaj9w", "Egljb21tdW5pdHm4AQCqAyQaIBIaVWd3cE9NQmVwWEdjclhsUHg2WjRBYUFCQ1FIZGgDKAA%3D").should eq("4qmFsgJoEhhVQ0NqOTU2SUY2MkZiVDdHb3VzemFqOXcaTEVnbGpiMjF0ZFc1cGRIbTRBUUNxQXlRYUlCSWFWV2QzY0U5TlFtVndXRWRqY2xoc1VIZzJXalJCWVVGQ1ExRklaR2dES0FBJTI1M0Q%3D")

      produce_channel_community_continuation("UC-lHJZR3Gqxm24_Vd_AJ5Yw", "Egljb21tdW5pdHm4AQCqAyQaIBIaVWd5RTI2NW1rUkk2cE9uS21nbDRBYUFCQ1FIZGgDKAA%3D").should eq("4qmFsgJoEhhVQy1sSEpaUjNHcXhtMjRfVmRfQUo1WXcaTEVnbGpiMjF0ZFc1cGRIbTRBUUNxQXlRYUlCSWFWV2Q1UlRJMk5XMXJVa2syY0U5dVMyMW5iRFJCWVVGQ1ExRklaR2dES0FBJTI1M0Q%3D")
      produce_channel_community_continuation("UC-lHJZR3Gqxm24_Vd_AJ5Yw", "Egljb21tdW5pdHm4AQCqA-cOCsAOUVVSVFNsOXBNWEYxYlVablFXaGFiWFJNTW5WM1ZHSXdPVU5EWTNoeFJWWlVjRWRGVTBOa1prTktjVUoyWjBZemNEZHRPV2cwV1hWbVJtaFVPWFJwVjJaUU4xTXlNRWRaYlZwSVFUa3dlak5pTUV0dll6QkRVMlpsWHpoVFdUbHFSR0o1YkRkM1kydEhMVTVwWDFCdFdXOUhjR0Z6ZEMxbldVcEhUMjkzUm1saGRXSkViVmR6ZFhwd1QxTnpOME54TW5KUloxQlBkME5QU1VWVWMybHlNbFZvUVV0NlVIZFVhMVV5UzNWUmJHRldkRmszU1dKd1pVUllVMkZFVG1aV1ZsRnVUMGhsZFd0T01sVndTbGd3TkhweVdDMVBTRUphV25GNk5Yb3dYMWRCVTFnMlltODBPRmhIV205WlQwNW1YMjV1UlVKTWNucHNNSGR5Y1hKaFltUkVkblJYZG1Kc1FVaHFUV3BwTkc5R1pUQkVlbGw2ZHpSM2FISlBTSFJoYjJGbVMwNTBiV1pxV2pCSVNWWnZTalpRT0RoclVGVmhia1p5VFhsaWFTMVBjREZZV1dSTFdERkZjSHB0ZUhseWFtRXdNR1JmTkhOWmFEVlZTbVZ1ZUVkRU1XRlFhbU4xVERabk4wdDVSSGxHU2xsT1VEQlJXR1ZLTUhGM1UwWkJTSE5oWkRWQ2NXZHNaMFpqYW1ST1YxZFlhMDVOVUZSSFZWVktRekZSYVhodlUxTm1SV1EwTUdsdWNEWXlPV1YwUjNkcGFVcEVTM040YUZadmRXbHJhblkyZFdFelNHWXpUV3hMYURCa2JIRTFSblJ4Wms4NU1XbGtOM0pHYjBGeU4xZFJNMU5qYkZCd05rZE9jV1JqT1hGRGIyNU5Xak5TUlhkemFsUXRObGt4UWxkUE16ZGFaRTlxVGtaZlIweEhRbXRNWXpCWE9GUjNOMHBsYVhwS2RtSlZkMmxGTVhCbVNIWkdkVTFJY0MxbFdYSkVZM0V0ZFROWWRtVlFlV3hhYlVKMmVreGZUMGxOU2xaSlRFTlBZMVpEUjFwd1RHZFhZMmhIYVVKakxUSmFabXd0U1RNeFJEWkhlSGhYTkhOMU1GZGhOMjFCVlVnNGNFTlJXSGx2WW5ScWNUaHZXWGxKT1d0TVRXc3lRMWc0Um5wU2JEVjBlRGxpTW5vMVRYaEtkelExY201S1JHSmZkamhmTlhOWmRGYzRjak5FVVdkMlpXVnNRWEJyZW5OdFpHcEljVGhWYzFsZkxWa3dRVTkyTVZVMmIyMTNVeTFLVEUxeFIwUldRbmc0VEdsTlpGVktjVmxzTkZGa1UwazFabE0wZUhsRk5WZ3lWR0ZaYzJadlYyaHRPRFpzTjNCT1dHRnBiMHhUVDBkMmRuZFVOMlptVm05dWIwRTFZVkZuYldKNmIwMUNaMng2VGkxSk56bHhXV3BJVGt4RFYwVllUM05pTVcwemRHc3lUVWN6TVVKcVRHdElNVWg1YmtKQmVrbFNVMnczZEVKUlJGOUlNVWRyZERsbFJraHVYekJXZUhGbE1rTTBlVE40YVU1T1pFcGpVMkpFZFMxWVdITjNTMnhWVjJwYVgzVXRXbGcwZG5OSE1qUXpYMlJHTVhSV1kxWkZRMlZwU25OdVlXTkdVek5wVUd4b2FUbDVSRVp4YVhsbFRqbG1aRWxYVFZCMVFWbG9OMEl3TW5KV1JUVjRkREJLZG5obmJGZHhSVlY1ZWpjMFIyeGlZemRIVmkxeFpESmlaMnhFZGxkcVRuSjZNVEZWUkRWamVIQlFkRk5DVmtSU2RITlRaSGhWZG05WE9VUkNhWEYwTm1kSFRtb3RNV1pNYlhSeVJWTnJhRWhIVDB0SU0yVkxUbFZ2V1VGNlJTMDJialJZYkRKdFFUVnJhRVJ4WmpjeFptcERNR001UmpkM2QwNW1VRXd5YUZCZlEwWjFSbEUzY0doRk5ISkZZMWxTTWs5d2RXRnhiRzFrYjBVMmIxWkJaRzkyU2xneFZWOXNiMDVWWkUxRFJ6QjBjWGhpVjBVMldYY3pTUzF4UVcxa1RuZEJRVGRvWVZFNGNsSTBaVUl0UmxacVdETnJXazVLY21aRk9HVndRbWxqUjB0blRFZEZVR3N6YzJOclkwSTNlVlZZVEdkcE1YQkdiMHAyZVU1aGRVZFdVblJQYVhaQlZtdHZSa0UzTFU1Sk1XaFJRMUpMV2kxSWJ6WkxjWEkxZGtSTWJsOVdUa0ZFVmpKZmMwUlFWV3gwUTJ0TFRsbDJaM2gxZFVOSVkzbEVORUpRZVUxMVREQnpOMVowWDI1MWRrVmlUMU54TkRkUk5rVjViMEpRTUZGNmR6RlJSR2RxY1U1eVgwNTBjMDkxWm14R2NUVjBlRkJGT1dGVmFXeFJTMEZYYldwQlVVbHNOVmgwZERZdGFFRlViMWxmUjFWc1EycG1WVkJQV0hkcFVRPT0aIBIaVWd5RTI2NW1rUkk2cE9uS21nbDRBYUFCQ1FIZGgDKGM%3D").should eq("4qmFsgKZFBIYVUMtbEhKWlIzR3F4bTI0X1ZkX0FKNVl3GvwTRWdsamIyMXRkVzVwZEhtNEFRQ3FBLWNPQ3NBT1VWVlNWRk5zT1hCTldFWXhZbFZhYmxGWGFHRmlXRkpOVFc1V00xWkhTWGRQVlU1RVdUTm9lRkpXV2xWalJXUkdWVEJPYTFwclRrdGpWVW95V2pCWmVtTkVaSFJQVjJjd1YxaFdiVkp0YUZWUFdGSndWakphVVU0eFRYbE5SV1JhWWxad1NWRlVhM2RsYWs1cFRVVjBkbGw2UWtSVk1scHNXSHBvVkZkVWJIRlNSMG8xWWtSa00xa3lkRWhNVlRWd1dERkNkRmRYT1VoalIwWjZaRU14YmxkVmNFaFVNamt6VW0xc2FHUlhTa1ZpVm1SNlpGaHdkMVF4VG5wT01FNTRUVzVLVWxveFFsQmtNRTVRVTFWV1ZXTXliSGxOYkZadlVWVjBObFZJWkZWaE1WVjVVek5XVW1KSFJsZGtSbXN6VTFkS2QxcFZVbGxWTWtaRlZHMWFWMVpzUm5WVU1HaHNaRmQwVDAxc1ZuZFRiR2QzVGtod2VWZERNVkJUUlVwaFYyNUdOazVZYjNkWU1XUkNWVEZuTWxsdE9EQlBSbWhJVjIwNVdsUXdOVzFZTWpWMVVsVktUV051Y0hOTlNHUjVZMWhLYUZsdFVrVmtibEpZWkcxS2MxRlZhSEZVVjNCd1RrYzVSMXBVUWtWbGJHdzJaSHBTTTJGSVNsQlRTRkpvWWpKR2JWTXdOVEJpVjFweFYycENTVk5XV25aVGFscFJUMFJvY2xWR1ZtaGlhMXA1VkZoc2FXRlRNVkJqUkVaWlYxZFNURmRFUmtaalNIQjBaVWhzZVdGdFJYZE5SMUptVGtoT1dtRkVWbFpUYlZaMVpVVmtSVTFYUmxGaGJVNHhWRVJhYms0d2REVlNTR3hIVTJ4c1QxVkVRbEpYUjFaTFRVaEdNMVV3V2tKVFNFNW9Xa1JXUTJOWFpITmFNRnBxWVcxU1QxWXhaRmxoTURWT1ZVWlNTRlpXVmt0UmVrWlNZVmhvZGxVeFRtMVNWMUV3VFVkc2RXTkVXWGxQVjFZd1VqTmtjR0ZWY0VWVE0wNDBZVVphZG1SWGJISmhibGt5WkZkRmVsTkhXWHBVVjNoTVlVUkNhMkpJUlRGU2JsSjRXbXM0TlUxWGJHdE9NMHBIWWpCR2VVNHhaRkpOTVU1cVlrWkNkMDVyWkU5alYxSnFUMWhHUkdJeU5VNVhhazVUVWxoa2VtRnNVWFJPYkd0NFVXeGtVRTE2WkdGYVJUbHhWR3RhWmxJd2VFaFJiWFJOV1hwQ1dFOUdVak5PTUhCc1lWaHdTMlJ0U2xaa01teEdUVmhDYlZOSVdrZGtWVEZKWTBNeGJGZFlTa1ZaTTBWMFpGUk9XV1J0VmxGbFYzaGhZbFZLTW1WcmVHWlVNR3hPVTJ4YVNsUkZUbEJaTVZwRVVqRndkMVJIWkZoWk1taElZVlZLYWt4VVNtRmFiWGQwVTFSTmVGSkVXa2hsU0doWVRraE9NVTFHWkdoT01qRkNWbFZuTkdORlRsSlhTR3gyV1c1U2NXTlVhSFpYV0d4S1QxZDBUVlJYYzNsUk1XYzBVbTV3VTJKRVZqQmxSR3hwVFc1dk1WUllhRXRrZWxFeFkyMDFTMUpIU21aa2FtaG1UbGhPV21SR1l6UmphazVGVlZka01scFhWbk5SV0VKeVpXNU9kRnBIY0VsalZHaFdZekZzWmt4V2EzZFJWVGt5VFZaVk1tSXlNVE5WZVRGTFZFVXhlRkl3VWxkUmJtYzBWRWRzVGxwR1ZrdGpWbXh6VGtaR2ExVXdhekZhYkUwd1pVaHNSazVXWjNsV1IwWmFZekphZGxZeWFIUlBSRnB6VGpOQ1QxZEhSbkJpTUhoVVZEQmtNbVJ1WkZWT01scHRWbTA1ZFdJd1JURlpWa1p1WWxkS05tSXdNVU5hTW5nMlZHa3hTazU2YkhoWFYzQkpWR3Q0UkZZd1ZsbFVNMDVwVFZjd2VtUkhjM2xVVldONlRWVktjVlJIZEVsTlZXZzFZbXRLUW1WcmJGTlZNbmN6WkVWS1VsSkdPVWxOVldSeVpFUnNiRkpyYUhWWWVrSlhaVWhHYkUxclRUQmxWRTQwWVZVMVQxcEZjR3BWTWtwRlpGTXhXVmRJVGpOVE1uaFdWakp3WVZnelZYUlhiR2N3Wkc1T1NFMXFVWHBZTWxKSFRWaFNWMWt4V2taUk1sWndVMjVPZFZsWFRrZFZlazV3VlVkNGIyRlViRFZTUlZwNFlWaHNiRlJxYkcxYVJXeFlWRlpDTVZGV2JHOU9NRWwzVFc1S1YxSlVWalJrUkVKTFpHNW9ibUpHWkhoU1ZsWTFaV3BqTUZJeWVHbFplbVJJVm1reGVGcEVTbWxhTW5oRlpHeGtjVlJ1U2paTlZFWldVa1JXYW1WSVFsRmtSazVEVm10U1UyUklUbFJhU0doV1pHMDVXRTlWVWtOaFdFWXdUbTFrU0ZSdGIzUk5WMXBOWWxoU2VWSldUbkpoUldoSVZEQjBTVTB5Vmt4VWJGWjJWMVZHTmxKVE1ESmlhbEpaWWtSS2RGRlVWbkpoUlZKNFdtcGplRnB0Y0VSTlIwMDFVbXBrTTJRd05XMVZSWGQ1WVVaQ1psRXdXakZTYkVVelkwZG9SazVJU2taWk1XeFRUV3M1ZDJSWFJuaGlSekZyWWpCVk1tSXhXa0phUnpreVUyeG5lRlpXT1hOaU1EVldXa1V4UkZKNlFqQmpXR2hwVmpCVk1sZFlZM3BUVXpGNFVWY3hhMVJ1WkVKUlZHUnZXVlpGTkdOc1NUQmFWVWwwVW14YWNWZEVUbkpYYXpWTFkyMWFSazlIVm5kUmJXeHFVakIwYmxSRlpFWlZSM042WXpKT2Nsa3dTVE5sVmxaWlZFZGtjRTFZUWtkaU1IQXlaVlUxYUdSVlpGZFZibEpRWVZoYVFsWnRkSFpTYTBVelRGVTFTazFYYUZKUk1VcE1WMmt4U1dKNldreGpXRWt4Wkd0U1RXSnNPVmRVYTBaRlZtcEtabU13VWxGV1YzZ3dVVEowVEZSc2JESmFNMmd4WkZWT1NWa3piRVZPUlVwUlpWVXhNVlJFUW5wT01Wb3dXREkxTVdSclZtbFVNVTU0VGtSa1VrNXJWalZpTUVwUlRVWkdObVI2UmxKU1IyUnhZMVUxZVZnd05UQmpNRGt4V20xNFIyTlVWakJsUmtKR1QxZEdWbUZYZUZKVE1FWllZbGR3UWxWVmJITk9WbWd3WkVSWmRHRkZSbFZpTVd4bVVqRldjMUV5Y0cxV1ZrSlFWMGhrY0ZWUlBUMGFJQklhVldkNVJUSTJOVzFyVWtrMmNFOXVTMjFuYkRSQllVRkNRMUZJWkdnREtHTSUyNTNE")
    end
  end

  describe "#extract_channel_community_cursor" do
    it "correctly extracts a community cursor from a given continuation" do
      extract_channel_community_cursor("4qmFsgIsEhhVQ0NqOTU2SUY2MkZiVDdHb3VzemFqOXcaEEVnbGpiMjF0ZFc1cGRIbTQ%3D").should eq("Egljb21tdW5pdHm4")
      extract_channel_community_cursor("4qmFsgJoEhhVQ0NqOTU2SUY2MkZiVDdHb3VzemFqOXcaTEVnbGpiMjF0ZFc1cGRIbTRBUUNxQXlRYUlCSWFWV2QzY0U5TlFtVndXRWRqY2xoc1VIZzJXalJCWVVGQ1ExRklaR2dES0FBJTI1M0Q%3D").should eq("Egljb21tdW5pdHm4AQCqAyQaIBIaVWd3cE9NQmVwWEdjclhsUHg2WjRBYUFCQ1FIZGgDKAA%3D")

      extract_channel_community_cursor("4qmFsgJoEhhVQy1sSEpaUjNHcXhtMjRfVmRfQUo1WXcaTEVnbGpiMjF0ZFc1cGRIbTRBUUNxQXlRYUlCSWFWV2Q1UlRJMk5XMXJVa2syY0U5dVMyMW5iRFJCWVVGQ1ExRklaR2dES0FBJTI1M0Q%3D").should eq("Egljb21tdW5pdHm4AQCqAyQaIBIaVWd5RTI2NW1rUkk2cE9uS21nbDRBYUFCQ1FIZGgDKAA%3D")
      extract_channel_community_cursor("4qmFsgKZFBIYVUMtbEhKWlIzR3F4bTI0X1ZkX0FKNVl3GvwTRWdsamIyMXRkVzVwZEhtNEFRQ3FBLWNPQ3NBT1VWVlNWRk5zT1hCTldFWXhZbFZhYmxGWGFHRmlXRkpOVFc1V00xWkhTWGRQVlU1RVdUTm9lRkpXV2xWalJXUkdWVEJPYTFwclRrdGpWVW95V2pCWmVtTkVaSFJQVjJjd1YxaFdiVkp0YUZWUFdGSndWakphVVU0eFRYbE5SV1JhWWxad1NWRlVhM2RsYWs1cFRVVjBkbGw2UWtSVk1scHNXSHBvVkZkVWJIRlNSMG8xWWtSa00xa3lkRWhNVlRWd1dERkNkRmRYT1VoalIwWjZaRU14YmxkVmNFaFVNamt6VW0xc2FHUlhTa1ZpVm1SNlpGaHdkMVF4VG5wT01FNTRUVzVLVWxveFFsQmtNRTVRVTFWV1ZXTXliSGxOYkZadlVWVjBObFZJWkZWaE1WVjVVek5XVW1KSFJsZGtSbXN6VTFkS2QxcFZVbGxWTWtaRlZHMWFWMVpzUm5WVU1HaHNaRmQwVDAxc1ZuZFRiR2QzVGtod2VWZERNVkJUUlVwaFYyNUdOazVZYjNkWU1XUkNWVEZuTWxsdE9EQlBSbWhJVjIwNVdsUXdOVzFZTWpWMVVsVktUV051Y0hOTlNHUjVZMWhLYUZsdFVrVmtibEpZWkcxS2MxRlZhSEZVVjNCd1RrYzVSMXBVUWtWbGJHdzJaSHBTTTJGSVNsQlRTRkpvWWpKR2JWTXdOVEJpVjFweFYycENTVk5XV25aVGFscFJUMFJvY2xWR1ZtaGlhMXA1VkZoc2FXRlRNVkJqUkVaWlYxZFNURmRFUmtaalNIQjBaVWhzZVdGdFJYZE5SMUptVGtoT1dtRkVWbFpUYlZaMVpVVmtSVTFYUmxGaGJVNHhWRVJhYms0d2REVlNTR3hIVTJ4c1QxVkVRbEpYUjFaTFRVaEdNMVV3V2tKVFNFNW9Xa1JXUTJOWFpITmFNRnBxWVcxU1QxWXhaRmxoTURWT1ZVWlNTRlpXVmt0UmVrWlNZVmhvZGxVeFRtMVNWMUV3VFVkc2RXTkVXWGxQVjFZd1VqTmtjR0ZWY0VWVE0wNDBZVVphZG1SWGJISmhibGt5WkZkRmVsTkhXWHBVVjNoTVlVUkNhMkpJUlRGU2JsSjRXbXM0TlUxWGJHdE9NMHBIWWpCR2VVNHhaRkpOTVU1cVlrWkNkMDVyWkU5alYxSnFUMWhHUkdJeU5VNVhhazVUVWxoa2VtRnNVWFJPYkd0NFVXeGtVRTE2WkdGYVJUbHhWR3RhWmxJd2VFaFJiWFJOV1hwQ1dFOUdVak5PTUhCc1lWaHdTMlJ0U2xaa01teEdUVmhDYlZOSVdrZGtWVEZKWTBNeGJGZFlTa1ZaTTBWMFpGUk9XV1J0VmxGbFYzaGhZbFZLTW1WcmVHWlVNR3hPVTJ4YVNsUkZUbEJaTVZwRVVqRndkMVJIWkZoWk1taElZVlZLYWt4VVNtRmFiWGQwVTFSTmVGSkVXa2hsU0doWVRraE9NVTFHWkdoT01qRkNWbFZuTkdORlRsSlhTR3gyV1c1U2NXTlVhSFpYV0d4S1QxZDBUVlJYYzNsUk1XYzBVbTV3VTJKRVZqQmxSR3hwVFc1dk1WUllhRXRrZWxFeFkyMDFTMUpIU21aa2FtaG1UbGhPV21SR1l6UmphazVGVlZka01scFhWbk5SV0VKeVpXNU9kRnBIY0VsalZHaFdZekZzWmt4V2EzZFJWVGt5VFZaVk1tSXlNVE5WZVRGTFZFVXhlRkl3VWxkUmJtYzBWRWRzVGxwR1ZrdGpWbXh6VGtaR2ExVXdhekZhYkUwd1pVaHNSazVXWjNsV1IwWmFZekphZGxZeWFIUlBSRnB6VGpOQ1QxZEhSbkJpTUhoVVZEQmtNbVJ1WkZWT01scHRWbTA1ZFdJd1JURlpWa1p1WWxkS05tSXdNVU5hTW5nMlZHa3hTazU2YkhoWFYzQkpWR3Q0UkZZd1ZsbFVNMDVwVFZjd2VtUkhjM2xVVldONlRWVktjVlJIZEVsTlZXZzFZbXRLUW1WcmJGTlZNbmN6WkVWS1VsSkdPVWxOVldSeVpFUnNiRkpyYUhWWWVrSlhaVWhHYkUxclRUQmxWRTQwWVZVMVQxcEZjR3BWTWtwRlpGTXhXVmRJVGpOVE1uaFdWakp3WVZnelZYUlhiR2N3Wkc1T1NFMXFVWHBZTWxKSFRWaFNWMWt4V2taUk1sWndVMjVPZFZsWFRrZFZlazV3VlVkNGIyRlViRFZTUlZwNFlWaHNiRlJxYkcxYVJXeFlWRlpDTVZGV2JHOU9NRWwzVFc1S1YxSlVWalJrUkVKTFpHNW9ibUpHWkhoU1ZsWTFaV3BqTUZJeWVHbFplbVJJVm1reGVGcEVTbWxhTW5oRlpHeGtjVlJ1U2paTlZFWldVa1JXYW1WSVFsRmtSazVEVm10U1UyUklUbFJhU0doV1pHMDVXRTlWVWtOaFdFWXdUbTFrU0ZSdGIzUk5WMXBOWWxoU2VWSldUbkpoUldoSVZEQjBTVTB5Vmt4VWJGWjJWMVZHTmxKVE1ESmlhbEpaWWtSS2RGRlVWbkpoUlZKNFdtcGplRnB0Y0VSTlIwMDFVbXBrTTJRd05XMVZSWGQ1WVVaQ1psRXdXakZTYkVVelkwZG9SazVJU2taWk1XeFRUV3M1ZDJSWFJuaGlSekZyWWpCVk1tSXhXa0phUnpreVUyeG5lRlpXT1hOaU1EVldXa1V4UkZKNlFqQmpXR2hwVmpCVk1sZFlZM3BUVXpGNFVWY3hhMVJ1WkVKUlZHUnZXVlpGTkdOc1NUQmFWVWwwVW14YWNWZEVUbkpYYXpWTFkyMWFSazlIVm5kUmJXeHFVakIwYmxSRlpFWlZSM042WXpKT2Nsa3dTVE5sVmxaWlZFZGtjRTFZUWtkaU1IQXlaVlUxYUdSVlpGZFZibEpRWVZoYVFsWnRkSFpTYTBVelRGVTFTazFYYUZKUk1VcE1WMmt4U1dKNldreGpXRWt4Wkd0U1RXSnNPVmRVYTBaRlZtcEtabU13VWxGV1YzZ3dVVEowVEZSc2JESmFNMmd4WkZWT1NWa3piRVZPUlVwUlpWVXhNVlJFUW5wT01Wb3dXREkxTVdSclZtbFVNVTU0VGtSa1VrNXJWalZpTUVwUlRVWkdObVI2UmxKU1IyUnhZMVUxZVZnd05UQmpNRGt4V20xNFIyTlVWakJsUmtKR1QxZEdWbUZYZUZKVE1FWllZbGR3UWxWVmJITk9WbWd3WkVSWmRHRkZSbFZpTVd4bVVqRldjMUV5Y0cxV1ZrSlFWMGhrY0ZWUlBUMGFJQklhVldkNVJUSTJOVzFyVWtrMmNFOXVTMjFuYkRSQllVRkNRMUZJWkdnREtHTSUyNTNE").should eq("Egljb21tdW5pdHm4AQCqA-cOCsAOUVVSVFNsOXBNWEYxYlVablFXaGFiWFJNTW5WM1ZHSXdPVU5EWTNoeFJWWlVjRWRGVTBOa1prTktjVUoyWjBZemNEZHRPV2cwV1hWbVJtaFVPWFJwVjJaUU4xTXlNRWRaYlZwSVFUa3dlak5pTUV0dll6QkRVMlpsWHpoVFdUbHFSR0o1YkRkM1kydEhMVTVwWDFCdFdXOUhjR0Z6ZEMxbldVcEhUMjkzUm1saGRXSkViVmR6ZFhwd1QxTnpOME54TW5KUloxQlBkME5QU1VWVWMybHlNbFZvUVV0NlVIZFVhMVV5UzNWUmJHRldkRmszU1dKd1pVUllVMkZFVG1aV1ZsRnVUMGhsZFd0T01sVndTbGd3TkhweVdDMVBTRUphV25GNk5Yb3dYMWRCVTFnMlltODBPRmhIV205WlQwNW1YMjV1UlVKTWNucHNNSGR5Y1hKaFltUkVkblJYZG1Kc1FVaHFUV3BwTkc5R1pUQkVlbGw2ZHpSM2FISlBTSFJoYjJGbVMwNTBiV1pxV2pCSVNWWnZTalpRT0RoclVGVmhia1p5VFhsaWFTMVBjREZZV1dSTFdERkZjSHB0ZUhseWFtRXdNR1JmTkhOWmFEVlZTbVZ1ZUVkRU1XRlFhbU4xVERabk4wdDVSSGxHU2xsT1VEQlJXR1ZLTUhGM1UwWkJTSE5oWkRWQ2NXZHNaMFpqYW1ST1YxZFlhMDVOVUZSSFZWVktRekZSYVhodlUxTm1SV1EwTUdsdWNEWXlPV1YwUjNkcGFVcEVTM040YUZadmRXbHJhblkyZFdFelNHWXpUV3hMYURCa2JIRTFSblJ4Wms4NU1XbGtOM0pHYjBGeU4xZFJNMU5qYkZCd05rZE9jV1JqT1hGRGIyNU5Xak5TUlhkemFsUXRObGt4UWxkUE16ZGFaRTlxVGtaZlIweEhRbXRNWXpCWE9GUjNOMHBsYVhwS2RtSlZkMmxGTVhCbVNIWkdkVTFJY0MxbFdYSkVZM0V0ZFROWWRtVlFlV3hhYlVKMmVreGZUMGxOU2xaSlRFTlBZMVpEUjFwd1RHZFhZMmhIYVVKakxUSmFabXd0U1RNeFJEWkhlSGhYTkhOMU1GZGhOMjFCVlVnNGNFTlJXSGx2WW5ScWNUaHZXWGxKT1d0TVRXc3lRMWc0Um5wU2JEVjBlRGxpTW5vMVRYaEtkelExY201S1JHSmZkamhmTlhOWmRGYzRjak5FVVdkMlpXVnNRWEJyZW5OdFpHcEljVGhWYzFsZkxWa3dRVTkyTVZVMmIyMTNVeTFLVEUxeFIwUldRbmc0VEdsTlpGVktjVmxzTkZGa1UwazFabE0wZUhsRk5WZ3lWR0ZaYzJadlYyaHRPRFpzTjNCT1dHRnBiMHhUVDBkMmRuZFVOMlptVm05dWIwRTFZVkZuYldKNmIwMUNaMng2VGkxSk56bHhXV3BJVGt4RFYwVllUM05pTVcwemRHc3lUVWN6TVVKcVRHdElNVWg1YmtKQmVrbFNVMnczZEVKUlJGOUlNVWRyZERsbFJraHVYekJXZUhGbE1rTTBlVE40YVU1T1pFcGpVMkpFZFMxWVdITjNTMnhWVjJwYVgzVXRXbGcwZG5OSE1qUXpYMlJHTVhSV1kxWkZRMlZwU25OdVlXTkdVek5wVUd4b2FUbDVSRVp4YVhsbFRqbG1aRWxYVFZCMVFWbG9OMEl3TW5KV1JUVjRkREJLZG5obmJGZHhSVlY1ZWpjMFIyeGlZemRIVmkxeFpESmlaMnhFZGxkcVRuSjZNVEZWUkRWamVIQlFkRk5DVmtSU2RITlRaSGhWZG05WE9VUkNhWEYwTm1kSFRtb3RNV1pNYlhSeVJWTnJhRWhIVDB0SU0yVkxUbFZ2V1VGNlJTMDJialJZYkRKdFFUVnJhRVJ4WmpjeFptcERNR001UmpkM2QwNW1VRXd5YUZCZlEwWjFSbEUzY0doRk5ISkZZMWxTTWs5d2RXRnhiRzFrYjBVMmIxWkJaRzkyU2xneFZWOXNiMDVWWkUxRFJ6QjBjWGhpVjBVMldYY3pTUzF4UVcxa1RuZEJRVGRvWVZFNGNsSTBaVUl0UmxacVdETnJXazVLY21aRk9HVndRbWxqUjB0blRFZEZVR3N6YzJOclkwSTNlVlZZVEdkcE1YQkdiMHAyZVU1aGRVZFdVblJQYVhaQlZtdHZSa0UzTFU1Sk1XaFJRMUpMV2kxSWJ6WkxjWEkxZGtSTWJsOVdUa0ZFVmpKZmMwUlFWV3gwUTJ0TFRsbDJaM2gxZFVOSVkzbEVORUpRZVUxMVREQnpOMVowWDI1MWRrVmlUMU54TkRkUk5rVjViMEpRTUZGNmR6RlJSR2RxY1U1eVgwNTBjMDkxWm14R2NUVjBlRkJGT1dGVmFXeFJTMEZYYldwQlVVbHNOVmgwZERZdGFFRlViMWxmUjFWc1EycG1WVkJQV0hkcFVRPT0aIBIaVWd5RTI2NW1rUkk2cE9uS21nbDRBYUFCQ1FIZGgDKGM%3D")
    end
  end

  describe "#sign_token" do
    it "correctly signs a given hash" do
      token = {
        "session" => "v1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "expires" => 1554680038,
        "scopes"  => [
          ":notifications",
          ":subscriptions/*",
          "GET:tokens*",
        ],
        "signature" => "f__2hS20th8pALF305PJFK-D2aVtvefNnQheILHD2vU=",
      }
      sign_token("SECRET_KEY", token).should eq(token["signature"])

      token = {
        "session"   => "v1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "scopes"    => [":notifications", "POST:subscriptions/*"],
        "signature" => "fNvXoT0MRAL9eE6lTE33CEg8HitYJDOL9a22rSN2Ihg=",
      }
      sign_token("SECRET_KEY", token).should eq(token["signature"])
    end
  end
end
