# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # user ||= User.new # We either have a user OR we create a default user

    # if user.atl?
    #   can :manage, :all
    # end
    if user.user_role?('admin')
      can :manage, :all
    else
      can :manage, Vendor if user.user_role?('atl')

      can :manage, Vendor do |vendor|
        user.user_role?('owner', vendor)
      end

      can :create, Vendor if user.user_role?('user')

      can :read, Vendor do |vendor|
        user.user_role?('vendor', vendor) ||
          user.user_role?('owner', vendor) ||
          user.user_role?('atl')
      end

      can :execute_task, Vendor do |vendor|
        user.user_role?('vendor', vendor) ||
          user.user_role?('owner', vendor) ||
          user.user_role?('atl')
      end

    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
