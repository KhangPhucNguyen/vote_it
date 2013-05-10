class FeedBackController < ApplicationController
    def index
        render "index"
    end

    def submit
      if request.post?
        answer = Answer.new request.POST
        logger.debug answer.inspect
        if answer.save
          redirect_to '/feed_back/overview' and return
        end
      end
      render 'index'
    end

    def overview
      answers = Answer.all
      unless answers.length == 0
        questions = Question.all
        @chart_data = {}

        questions.each do |q|
          @chart_data[q._id.to_s] = 0
        end

        answers.each do |ans|
          ans = ans.answers
          ans.each do |key, value|
            question = Question.find(key)
            if question.type == 1
              @chart_data[key] += value.to_i
            end
          end
        end

        @chart_data.each do |key, value|
          @chart_data[key] = value/Float(answers.length)
        end

        render 'overview' and return
      end
      redirect_to root_path
    end
end
