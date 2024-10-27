# frozen_string_literal: true

class FindMatch
  include Base

  attr_reader :tv, :movie

  NAME = "([a-z\\-\\s0-9]*)\\s"
  DELIMITER = "[\\sa-z]*"
  RESOLUTION = "(\\d{3,4}p|\\dk)+"

  def initialize(title:)
    @title = title
  end

  def perform
    tv_match = find_tv_match(title: @title)
    @tv = tv_match if tv_match[:name]
    @movie = find_movie_match(title: @title)
  end

  private

  def find_movie_match(title:)
    work = title.gsub(".", " ").downcase

    re_year = /\s\(?(\d{4})\)?\s/
    re_res = Regexp.new(RESOLUTION)

    split = work.split(re_year)
    name = split.shift
    year = split.shift
    post = split.join

    if m = post.match(re_res)
      resolution = m[1]
    end

    cam = !!work.match(/cam/) || !!work.match(/telesync/)

    { name: name, year: year, resolution: resolution, cam: cam }
  end

  def find_tv_match(title:)
    work = title.gsub(".", " ").downcase
    name = season = episode = resolution = nil
    
    # s.e
    re_se = "s(\\d{1,2})e(\\d{1,2})"
    re_s = "s(\\d{1,2})"
    # .x.
    re_x = "(\\d{1,2})x(\\d{1,2})"

    if (match_se = work.match(Regexp.new("#{NAME}#{re_se}#{DELIMITER}#{RESOLUTION}")))
      name = match_se[1]
      season = match_se[2]
      episode = match_se[3]
    end

    if (match_s = work.match(Regexp.new("#{NAME}#{re_s}#{DELIMITER}#{RESOLUTION}")))
      name ||= match_s[1]
      season ||= match_s[2]
    end

    if (match_x = work.match(Regexp.new("#{NAME}#{re_x}#{DELIMITER}#{RESOLUTION}")))
      name ||= match_se[1]
      season ||= match_se[2]
      episode ||= match_se[3]
    end

    { name: name, season: season, episode: episode, resolution: resolution }
  end
end
