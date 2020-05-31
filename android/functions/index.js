const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;

exports.onCreateFollower = functions.firestore

    .document("/follower/{userId}/userfollower/{followerId}")
    .onCreate(async(snapshot , context) => {
    console.log('follower created' , snapshot.id);
    const userId  =  context.params.userId;
    const followerId = context.params.followerId;
    const followedUserPostRef = admin
    .firestore()
    .collection('posts')
    .doc(userId)
    .collection('userpost')

    const timelinePostRef = admin
    .firestore()
    .collection('timeline')
    .doc(followerId)
    .collection('timelinePost')
const querySnapshot = await followedUserPostRef.get();

querySnapshot.forEach(doc => {
if(doc.exists){
    const postId = doc.id;
    const postData = doc.data();
    timelinePostRef.doc(postId).set(postData);
}
});
});

//function to delete timeline when we unfollow
//
//
//
//
//

exports.onDeleteFollower = functions.firestore
    .document("/follower/{userId}/userfollower/{followerId}")
    .onDelete(async (snapshot , context) => {
    console.log('follower deleted');
    const userId  =  context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostRef = admin
    .firestore()
    .collection('timeline')
    .doc(followerId)
    .collection('timelinePost')
    .where('ownerId' ,"==", userId);

const querySnapshot =await timelinePostRef.get();
    querySnapshot.forEach(doc =>{
        if(doc.exists){
        doc.ref.delete();
        }
        });

});
// to vreate post on the timeline
//
//
//
//
//

exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/userpost/{postId}')
    .onCreate(async(snapshot , context) =>{
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;
    // to get all the users followers
    const userFollowerRef =admin.
    firestore()
    .collection('follower')
    .doc(userId)
    .collection('userfollower');

    const querySnapshot = await userFollowerRef.get();
    // to add the post to follower timeline
querySnapshot.forEach(doc =>{
const followerId = doc.id;
admin.firestore()
.collection('timeline')
.doc(followerId)
.collection('timelinePost')
.doc(postId)
.set(postCreated);
});

});
// to update the post to the time line when changed
//
//
//
//
//

//firebase deploy --only functions

exports.onUpDatePost =functions.firestore
.document('/posts/{userId}/userpost/{postId}')
.onUpdate(async(change , context) =>{
 const postUpdated = change.after.data();
 const userId = context.params.userId;
 const postId = context.params.postId;
     // to get all the users followers

      const userFollowerRef =admin.
         firestore()
         .collection('follower')
         .doc(userId)
         .collection('userfollower');

         const querySnapshot = await userFollowerRef.get();
         // to add the post to follower timeline
     querySnapshot.forEach(doc =>{
     const followerId = doc.id;
     admin.firestore()
     .collection('timeline')
     .doc(followerId)
     .collection('timelinePost')
     .doc(postId)
     .get()
     .then(doc=>{
     const updated =  doc.ref.update(postUpdated);
     return updated;
     }).catch(error =>{
     console.log('error');
     response.status(500).send(error);

     })


     });

});
// ===================================
//
//
//
//

exports.onDeletePost =functions.firestore
.document('/posts/{userId}/userpost/{postId}')
.onDelete(async(snapshot , context) =>{
 const userId = context.params.userId;
 const postId = context.params.postId;

    const userFollowerRef =admin.
          firestore()
          .collection('follower')
          .doc(userId)
          .collection('userfollower');

          const querySnapshot = await userFollowerRef.get();
                   // to add the post to follower timeline
                   querySnapshot.forEach(doc =>{
                   const followerId = doc.id;
                   admin.firestore()
                   .collection('timeline')
                   .doc(followerId)
                   .collection('timelinePost')
                   .doc(postId)
                   .get()
                   .then(doc=>{
                   const updated =  doc.ref.delete();
                   return updated;
                   }).catch(error =>{
                   console.log('error');
                   response.status(500).send(error);

           })


     });


})
// {userId} ,  {postId} cuz they are unknown and we usr them to represent them
// we them because they are unknown values in the collection
//
//
//
//
//
exports.onCreateActivityFeed = functions
.firestore
.document('/feed/{userId}/feeditems/{feedItem}')
.onCreate(async(snapshot,context) => {
// we are connecting user to the feed
 const userId = context.params.userId;
 //
 const userRef = firestore()
 .doc(`users/${userId}`);
 //
 const docs = await userRef.get();

 // now we are checking if the user as a notification token
  const notificationToken = doc
  .data()
  .androidNotificationToken;
  if(androidNotificationToken){
  sendNotification(androidNotificationToken , snapshot.data());

  }else{
  console.log('no ,no,send');
  }
function sendNotification(androidNotificationToken , feedItem){
    let body;
//as there is different types in activity feed
    switch(feedItem.type){
        case "comment":
            body =`${feedItem.username} replied:${feedItem.comment}`;
            break;
        case 'like':
            body = `${feedItem.username} liked your post`;
            break;
        case 'follow':
            body = `${feedItem.username} follows you`
            break;
        default:
            break;
}
// now we create message
    const message = {
    notification:{body},
    token:androidNotificationToken,
    data:{recipient : userId}
    }
    admin.firestore()
    .send(message)
    .then(response =>{
    const res = console.log('sent' , response);
    return res;
    }).catch(error =>{
    console.log(error);
    }

    )}



})