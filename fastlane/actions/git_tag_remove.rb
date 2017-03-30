module Fastlane
  module Actions
    module SharedValues
      GIT_TAG_REMOVE_CUSTOM_VALUE = :GIT_TAG_REMOVE_CUSTOM_VALUE
    end

    class GitTagRemoveAction < Action
      def self.run(params)
        tagName = params[:tag]
        removeRL = params[:rL]
        removeRR = params[:rR];
        #创建数组
        arrs = []
        # local
        if removeRL
        
            arrs <<"git tag -d #{tagName}"
        end
        # remote
        if removeRR
            arrs <<"git push origin :#{tagName}"
        end
  
        result = Actions.sh(arrs.join('&'));
        return result
      end

      def self.description
        "Remove local and remote tags"
      end

      def self.details
        "We can use this command to remove local and remote tags"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :tag,
                             description: "tag which will be removed",
                             is_string: true),
          FastlaneCore::ConfigItem.new(key: :rL,
                             description: "weather to remove local tag",
                             optional:true,
                             is_string: false,
                             default_value:true),
          FastlaneCore::ConfigItem.new(key: :rR,
                             description: "weather to remove remote tag",
                             optional:true,
                             is_string: false,
                             default_value:true)
        ]
      end

      def self.output


      end

      def self.return_value
        nil
      end

      def self.authors
        ["Github:mcmengchen"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
