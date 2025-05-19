import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/common/birdo_toast.dart';
import 'package:birdo/view/widgets/new_friend_modal.dart';
import 'package:birdo/view/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class TaskList extends StatelessWidget {
  final VoidCallback? onTaskTap;

  const TaskList({super.key, this.onTaskTap});

  static const List<String> _congratsMessages = [
    'Congrats!',
    'Well done!',
    'Keep it up!',
    'Woot!',
    'Huzzah!',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskManager>(
      builder: (context, taskManager, child) {
        // Get the task controller
        final taskController = Provider.of<TaskController>(context, listen: false);
        
        // Check if tasks are initialized
        if (!taskManager.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Get the tasks
        final tasks = taskManager.tasks;
        
        // Build the task list
        List<Widget> children = [];
        
        if (tasks.isEmpty) {
          children.add(
            Center(
              child: Text(
                taskManager.isTimeTravel 
                    ? 'No tasks for this day' 
                    : 'No tasks yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600]
                ),
              ),
            ),
          );
        } else {
          for (var task in tasks) {
            children.add(
              TaskCard(
                task: task,
                onTap: onTaskTap,
                onCheckboxChanged: (isCompleted) async {
                  if (isCompleted == true) {
                    await taskController.completeTask(task.id);

                    final numCompleted = await taskManager.getNumCompleted(task);
                    if (numCompleted != null) {
                      if (numCompleted > 1 && numCompleted < 7) {
                        // Completed between 2 and 6 times, encourage the user.
                        BirdoToastManager.showSuccess(
                          context, // Elli: Not sure how to deal with this warning. Can't use a `mounted` check cause this is a stateless widget.
                          message: "🎉 ${_congratsMessages[DateTime.now().millisecondsSinceEpoch % 5]} You completed ${task.title} $numCompleted times!",
                        );
                      } else if (numCompleted == 7) {
                        // Completed 7 times, the user meets a new friend.
                        /* Elli: The full app will have more pets, and further
                           progression beyond 7 completions. */
                        showDialog(
                          context: context, // Elli: See note above about `mounted` warning.
                          builder: (_) => NewFriendModal(
                            taskTitle: task.title,
                            taskNumCompleted: numCompleted,
                            onClose: () => Navigator.of(context).pop(),
                          ),
                        );
                      }
                    }
                  } else {
                    await taskController.resetTask(task.id);
                  }
                },
              ),
            );
          }
        }
        
        return children.isEmpty
            ? const SizedBox.shrink()
            : ListView(children: children);
      },
    );
  }
}
