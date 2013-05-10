class PollSetController < ApplicationController
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
      @poll_sets = PollSet.where(:active => true).paginate(:page => params[:page], :per_page => 10)
      render 'list' and return
    end
    redirect_to '/signin'
  end

  def view
    if signed_in?
      if request.get? && !params['poll_set_id'].nil?
        @poll_set = get_object params['poll_set_id']
        if !@poll_set.nil? && @poll_set.active
          @polls = @poll_set.polls.active_polls.paginate(:page => params[:page], :per_page => 10)
          render 'view' and return
        end
        flash[:message] = 'The poll_set is inactive now.'
      end
    end
    redirect_to root_path
  end

  def delete
    if signed_in?
      unless params['poll_set_id'].nil?
        @poll_set = get_object params['poll_set_id']
        unless @poll_set.nil?
          @poll_set.delete
          redirect_to request.referer and return
        end
      end
    end
    redirect_to root_path
  end

  def edit
    if signed_in?
      unless params['poll_set_id'].nil?
        @poll_set = get_object params['poll_set_id']
        unless params['poll_set'].nil? || @poll_set.nil?
          @poll_set.attributes = params['poll_set']
          if @poll_set.valid? && @poll_set.save
            redirect_to "/poll_set/view/#{@poll_set._id}" and return
          end
        end
      end
      render 'edit' and return
    end

    redirect_to root_path
  end

  def activate
    if signed_in?
      unless params['poll_set_id'].nil?
        @poll_set = get_object params['poll_set_id']
        unless @poll_set.nil?
          @poll_set.active = true
          if @poll_set.valid?
            @poll_set.save
          end
        end
      end
    end
    redirect_to root_path
  end

  def deactivate
    if signed_in?
      unless params['poll_set_id'].nil?
        @poll_set = get_object params['poll_set_id']
        unless @poll_set.nil?
          @poll_set.active = false
          if @poll_set.valid?
            @poll_set.save
          end
        end
      end
    end
    redirect_to root_path
  end

  def create
    if signed_in?
      if params['poll_set_id']
        begin
          @poll_set = PollSet.find(params['poll_set_id'])
        rescue
        end
      end
      @poll_set = PollSet.new

      if request.post? && !params['poll_set'].nil?
        @poll_set.attributes = params['poll_set']
        if @poll_set.valid?
          user = current_user
          user.poll_sets.push(@poll_set)
          if user.save && @poll_set.save
            flash[:message] = "New vote set has been created successfully"
            redirect_to "/poll_set/admin" and return
          end
        end
      end
      render 'create' and return
    else
      render '/signin'
    end
  end

  def overview
    if signed_in?
      unless params['poll_set_id'].nil?
        @poll_set = get_object params['poll_set_id']
        options = @poll_set.poll_set_options
        @chart_data = {}
        options.each do |opt|
          @chart_data[opt._id.to_s] = 0
          opt.poll_set_answers.each do |ans|
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
      return PollSet.find(id)
    rescue
      return nil
    end
  end

end
