# coding:utf-8
require "open-uri"
require "json"
require "time"
require 'pry'

module News

  class Parser
    class << self
      def read_dat(file)
        open(file, 'r:Shift_JIS').read
        .encode("UTF-8", invalid: :replace, undef: :replace)
      end
    end
  end
  
  class Ikioi
    def initialize(board_name = "poverty")
      url = "http://2ch-ranking.net/ranking.json?board=#{board_name}&callback=callback"
      raw_ikioi_str = Parser::read_dat(url)
      ikioi_str = raw_ikioi_str.gsub(/^callback\(/,"").gsub(/\);$/,"")
      @ikioi_arr = JSON.parse(ikioi_str)
    end

    def datfile(num = 1)
      # example:  News.datfile => "1281073407.dat"
      if (1..100).include? num
        url = @ikioi_arr[num - 1]["url"]
        thread_id = url.split("/").last
        dat_file = "#{thread_id}.dat"
        return dat_file
      else
        false
      end
    end

    def details(num = 1)
      #   example:
      #   News.details =>
      #   {"rank"=>"1",
      #   "updown"=>"new",
      #   "url"=>"engawa.2ch.net/poverty/1381073407/",
      #   "title"=>"【速報】アニメDVD・BDの売り上げを見守るスレ13917 ",
      #   "res"=>"999",
      #   "ikioi"=>"31246"}
      if (1..100).include? num
        return @ikioi_arr[num - 1]
      else
        return false
      end
    end

  end


  class Thread

    attr_reader :title, :res_count
    def initialize(dat)
      @dat = dat
      @title = get_title
      @thread_data = thread_data_to_array 
      @res_count = @thread_data.count 
    end

    def res(num = 1)
      # example News::Thread.res =>
      # {"number"=>1,
      # "name"=>"番組の途中ですがアフィサイトへの転載は禁止です",
      # "date_str"=>"2013/10/08(火) 21:59:59.38 ID:Me1TT+g+0",
      # "date"=>2013-10-08 21:59:59 +0900,
      # "text"=> "本文"}
      if (1..@res_count).include? num
        return @thread_data[num -1]
      else
        return @thread_data.last
      end
    end

    def find_id(id = "sample")
      result = []
      @thread_data.each do |res_data|
        if res_data["date"].include?(id)
          result << res_data
        end
      end
      return result
    end

    def to_res(num =1)
      result = []
      @thread_data.each do |res_data|
        if res_data["text"].include?("&gt;&gt;#{num}</a>")
          result << res_data
        end
      end
      return result
    end

    def popular_res
      result = []
      1.upto(@res_count) do |i|
        if to_res(i).size >= 3
          result << res(i)
        end
      end
      return result
    end

    private
    def thread_data_to_array
      url = "http://engawa.2ch.net/poverty/dat/#{@dat}"
      return Parser::read_dat(url).lines.map.with_index do |line, i| 
        res_data = line.split("<>")
       {
          number: i,
          name: res_data[0].strip,
          date_str: res_data[2],
          date: ( i == 1000 ? "" : Time.parse(res_data[2].split("ID").first) ),
          text: res_data[3].strip
        }
      end
    end

    def get_title
      subject_url = "http://engawa.2ch.net/poverty/subject.txt"
      raw_subject = Parser::read_dat(subject_url)
      raw_subject.each_line do |data|
        if data.include?(@dat)
          return data.split("<>")[1].chomp.sub(/\([0-9]+\)$/,"").strip
        end
      end
    end

  end

end


