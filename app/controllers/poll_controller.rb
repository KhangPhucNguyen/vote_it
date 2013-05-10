class PollController < ApplicationController
  layout "application"

  def admin
    if signed_in?
      @poll_sets = current_user.poll_sets.all.paginate(:page => params[:page], :per_page => 10)
      render 'admin' and return
    end
    redirect_to '/signin'
  end

  def list
    if signed_in?
      @polls = Poll.where(:active => true).paginate(:page => params[:page], :per_page => 10)
      render 'list' and return
    end
    redirect_to '/signin'
  end

  def view
    if signed_in?
      if request.get? && !params['poll_id'].nil?
        @poll = get_object params['poll_id']
        if !@poll.nil? && @poll.active
          @poll_answer = PollAnswer.new
          render 'view' and return
        end
        flash[:message] = 'The poll is inactive now.'
      end
    end
    redirect_to root_path
  end

  def answer
    if signed_in?
      if request.post? && !params['poll_answer'].nil? && !params['poll'].nil?
        user = current_user
        poll_id = params['poll']['id']
        @poll = get_object poll_id
        answered = nil
        @poll.poll_options.each do |option|
          answers = PollAnswer.where(:poll_option_id => option._id, :user_id => user._id)
          if answers.length > 0
            answered = answers.first
            break
          end
        end
        if answered.nil?
          poll_option = @poll.poll_options.find_by_id params['poll_answer']['poll_option_id']
          poll_answer = PollAnswer.new
          if poll_answer.valid?
            poll_option.poll_answers.push poll_answer
            user.poll_answers.push poll_answer
            if user.valid? && user.save && poll_option.valid? && poll_option.save
              redirect_to "/poll/overview/#{@poll._id}" and return
            else
              render 'view' and return
            end
          end
        else
          flash[:message] = 'You already voted for this.'
          redirect_to "/poll/view/#{@poll._id}" and return
        end
      end
    end
    redirect_to root_path
  end

  def delete
    if signed_in?
      unless params['poll_id'].nil?
        @poll = get_object params['poll_id']
        unless @poll.nil?
          @poll.delete
          redirect_to request.referer and return
        end
      end
    end
    redirect_to root_path
  end

  def edit
    if signed_in?
      @poll = get_object params['id']
      unless @poll.nil?
        if request.put?
          @poll.attributes = params['poll']
          if @poll.valid? && @poll.save
            redirect_to "/poll/view/#{@poll._id}" and return
          end
        end
        render 'edit' and return
      else
        flash[:message] = "Can not find the poll"
      end
    end

    redirect_to root_path
  end

  def update
    if signed_in? && !request.get? && !params['poll'].nil? && !params['poll_options'].nil?
      @poll = get_object params['poll']['id']
      unless @poll.nil?
        if request.put?
          @poll.attributes = params['poll']
          if @poll.valid? && @poll.save
            params['poll_options'].each do |key, value|
              unless value['name'].strip.empty?
                poll_option = PollOption.new (value)
                if poll_option.valid?
                  poll_option.poll = @poll
                  poll_option.save
                end
              end
            end
            redirect_to "/poll/view/#{@poll._id}" and return
          end
        end
        render 'edit' and return
      else
        flash[:message] = "Can not find the poll"
      end
    end
    redirect_to root_path
  end

  def activate
    if signed_in?
      unless params['poll_id'].nil?
        @poll = get_object params['poll_id']
        unless @poll.nil?
          @poll.active = true
          if @poll.valid?
            @poll.save
          end
        end
      end
    end
    redirect_to root_path
  end

  def deactivate
    if signed_in?
      unless params['poll_id'].nil?
        @poll = get_object params['poll_id']
        unless @poll.nil?
          @poll.active = false
          if @poll.valid?
            @poll.save
          end
        end
      end
    end
    redirect_to root_path
  end

  def new
    if signed_in?
      @poll = Poll.new

      unless params['poll_set_id'].nil? || params['poll_set_id'].empty?
        @poll_set = get_poll_set params['poll_set_id']
        if @poll_set.nil?
          flash[:message] = "Can not find the poll set"
          redirect_to root_path and return
        end
      end

      render 'create' and return
    end
    redirect_to root_path
  end

  def create
    if signed_in? && request.post? && !params['poll'].nil? && !params['poll_options'].nil?
      @poll = Poll.new
      @poll.attributes = params['poll']

      unless params['poll_set_id'].nil? || params['poll_set_id'].empty?
        @poll_set = get_poll_set params['poll_set_id']
        if @poll_set.nil?
          flash[:message] = "Can not find the poll set"
          redirect_to root_path and return
        end
      else
        @poll_set = PollSet.new
        @poll_set.name = DateTime.now.strftime("#{current_user.username} %d/%m/%Y %H:%M")
      end

      if @poll.valid?
        params['poll_options'].each do |key, value|
          unless value['name'].strip.empty?
            poll_option = PollOption.new (value)
            if poll_option.valid?
              poll_option.poll = @poll
              poll_option.save
            end
          end
        end
        if @poll.poll_options.length > 1 && @poll.save
          @poll_set.user = current_user
          @poll.poll_set = @poll_set
          if @poll_set.save && @poll.save
            flash[:message] = "New vote has been created successfully"
            redirect_to "/poll_set/view/#{@poll.poll_set_id}" and return
          end
        else
          flash[:message] = "Poll options must be more than 1"
        end
        render 'create' and return
      end
    end
    redirect_to root_path and return
  end

  def submit
    if request.post?
      answer = Answer.new request.POST
      if answer.save
        redirect_to '/feed_back/overview' and return
      end
    end
    render 'index'
  end

  def overview
    if signed_in?
      unless params['poll_id'].nil?
        @poll = get_object params['poll_id']
        options = @poll.poll_options
        @chart_data = {}
        options.each do |opt|
          @chart_data[opt._id.to_s] = 0
          opt.poll_answers.each do |ans|
            @chart_data[opt._id.to_s] += 1
          end
        end
        tmp = @chart_data.sort {|a1,a2| a2[1]<=>a1[1]}
        tmp = Hash[tmp]
        @biggest = tmp.values[0]
        render 'overview' and return
      end
    end
    redirect_to root_path
  end

  protected

  def get_object (id)
    begin
      return Poll.find(id)
    rescue
      return nil
    end
  end

  def get_poll_set (id)
    begin
      return PollSet.find(id)
    rescue
      return nil
    end
  end

end

